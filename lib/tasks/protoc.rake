namespace :protoc do
  desc "Compile Protobuf and generate ruby code"
  task compile: :environment do
    compile
    remove_unnecessary_require
  end

  private

  def proto_path
    File.join(Rails.root, "proto")
  end

  def grpc_path
    File.join(Rails.root, "grpc")
  end

  def ruby_out
    File.join(grpc_path, "lib")
  end

  def grpc_out
    ruby_out
  end

  def grpc_ruby_plugin_path
    `which grpc_ruby_plugin`.chomp
  end

  def proto_files
    Dir.glob(File.join(Rails.root, "proto", "*.proto"))
  end

  def compile
    command = <<-EOS
protoc -I #{proto_path} --ruby_out=#{ruby_out} --grpc_out=#{grpc_out} \
--plugin=protoc-gen-grpc=#{grpc_ruby_plugin_path} #{proto_files.join(" ")}
    EOS
    puts "Compile Protobuf..."
    puts command
    `#{command}`
  end

  def grpc_out_ruby_files
    Dir.glob(File.join(ruby_out, "**/*.rb"))
  end

  # FIXME:
  #   - Load the definition of protobuf twice will result in an error
  #     so we remove the require pb definition.
  #     This is not a smart way, we need to fix it.
  def remove_unnecessary_require
    service_files = grpc_out_ruby_files.select do |v|
      name = File.basename(v)
      name.end_with?("_pb.rb") && name.include?("_services_")
    end
    service_files.each do |path|
      source = open(path)
        .read
        .split("\n")
        .reject { |line| line =~ /^require / && !line.include?("grpc") }.join("\n")
      open(path, "w") do |f|
        f.write source
      end
    end
  end
end
