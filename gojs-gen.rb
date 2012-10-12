#!/usr/bin/env ruby
require 'rubygems'
require 'trollop'
require 'pathname'
require 'fileutils'
require 'digest/sha1'
require 'date'
require 'base64'

######################
# Function definitions
######################

# The file "id" is necessary because each file included by typoscript needs
# a unique identifier, which we compose of the extension name and a shortened
# hash of the file path, e.g. "tx_gojsfoo_ff7b"
def file_id(ext_name, path)
  short_ext_name = ext_name.gsub("_", "")
  hash = (Digest::SHA1.hexdigest path)[0, 4]
  id = "tx_#{short_ext_name}_#{hash}"
end


# Generate ext_typoscript_setup.txt
def generate_typoscript_setup(ext_name, js_files, asset_files)
  typoscript = "# This file was automatically generated by gojs-gen.rb\n\n"

  js_files.each do |f|
    typoscript += "page.includeJS.#{file_id(ext_name, f)} = EXT:#{f}\n"
  end

  typoscript += "\n"

  asset_files.select { |f| File.extname(f) == ".css" }.each do |f|
    typoscript += "page.includeCSS.#{file_id(ext_name, f)} = EXT:#{f}\n"
  end

  typoscript
end



#################################
# Command line parameter checking
#################################

opts = Trollop::options do
  version "gojs-generator v0.1"
  banner <<-EOS
Usage:
       gojs-gen [options] <filenames>+

where [options] are:
EOS

  opt :js_version, "Version of the JavaScript library (e.g. 1.2.3)", :short => "-j", :type => :string
  opt :ext_name, "Name of the extension to be generated, e.g. 'foo' will yield 'gojs_foo'", :short => "-e", :type => :string
  opt :author, "Your name, not who created the JavaScript", :short => "-a", :type => :string
  opt :title, "Title of the generated extension in the extension manager", :short => "-t", :type => :string
end

[:js_version, :ext_name, :author, :title].each do |s|
  Trollop::die s, "must be specified" if not opts[s]
end

abort "You must specify at least one file to be included." if ARGV.empty?

ARGV.each do |f|
  abort "Given file '#{f}' does not exist." unless File.exists? f
  abort "'#{f}' is a directory, not a file." if File.directory? f
end



####################
# Extension creation
####################

# These are the subdirectories created inside the new extension
$subdirectories = ["assets", "src"]

$name = "gojs_#{opts[:ext_name]}"
$version = opts[:js_version]
$js_files = ARGV.select { |f| File.extname(f) == ".js" }
$asset_files = ARGV.select { |f| File.extname(f) != ".js" }

abort "Directory '#{$name}' already exists." if File.exists? $name


# Creating extension directories
FileUtils.mkdir $name
$subdirectories.each { |d| FileUtils.mkdir "#{$name}/#{d}" }


# Copying javascript files ...
$js_files = $js_files.map do |f|
  targetPath = "#{$name}/src/#{Pathname.new(f).basename}"
  FileUtils.cp f, targetPath
  targetPath
end

# ... and assets
$asset_files = $asset_files.map do |f|
  targetPath = "#{$name}/assets/#{Pathname.new(f).basename}"
  FileUtils.cp f, targetPath
  targetPath
end

# Write ext_typoscript_setup.txt
File.open("#{$name}/ext_typoscript_setup.txt", "w") do |f|
  f.write generate_typoscript_setup($name, $js_files, $asset_files)
end

# Write ext_emconf.php
ext_emconf = """
<?php

# Extension Manager/Repository config file for ext '#{$name}'.
# Auto generated at #{DateTime.now}

$EM_CONF[$_EXTKEY] = array(
  'title' => '#{opts[:title]}',
  'description' => '',
  'category' => 'plugin',
  'author' => '#{opts[:author]}',
  'author_email' => 'web@gosign.de',
  'shy' => '',
  'dependencies' => '',
  'conflicts' => '',
  'priority' => '',
  'module' => '',
  'state' => 'beta',
  'internal' => '',
  'uploadfolder' => 0,
  'createDirs' => '',
  'modify_tables' => '',
  'clearCacheOnLoad' => 0,
  'lockType' => '',
  'author_company' => 'Gosign media. GmbH',
  'version' => '#{opts[:js_version]}',
  'constraints' => array(
    'depends' => array(),
    'conflicts' => array(),
    'suggests' => array(),
  ),
  '_md5_values_when_last_written' => '',
  'suggests' => array(),
);
"""

File.open("#{$name}/ext_emconf.php", "w") do |f|
  f.write ext_emconf
end


# Write ext_icon.gif
File.open("#{$name}/ext_icon.gif", "wb") do |f|
  f.write Base64.decode64("R0lGODlhEgAQAOZrAO+KK/3u4P3t3+6FI/a+iv77+PKfUu+KLPnSrvvgx//9+/Svb/jMovOrZv769vKhVvrbvvCPNPrYuP717O+LLfa+ifvgyP738PKcTfOnYe14DPzn1PfGmPfHm/KfUfW4f/SydPfBj/zq2fGXQ/Syc/fFlvvkz+x1BvfElPravP727u17EfOlXfW1eu6EIvjMo/vl0P717e15Dfrew+5/GfnXtvGaSfCUPvnQqvnRq/SvbvSsafStavCSOu19Ff306vGaSPfElfKdTv3w5PjNpP727//8+vrYue+IJ/nUse6GJPW0ePOmX/zr3Pa/i/bAje15Dux1BfKdT/CQNvSrZ+1+FvKhVfW3ffCOM+6BHPjOp/zr2++IKPrXt/a/jPCQN/a6g/zo1vW3fPa7hPCUPfzs3fKeUPa7hex2CPCROex0BP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAGsALAAAAAASABAAAAfWgGuCg4QTVl8zhIoJBhkXa2Nqag2KgwI+khVrQpJEa11DihCSalMFEWouBSRqTIoOI5IyMABqKE6SS4MFDmsxtWovAwAdkjsKghIHXFQJATdqZz0fNAAMAmGCSqRqHjULCAIlDQRmGkiCB9xqWWWCAWSkLYJNHARPIQQVE4IIYB04Uija4gVIFRtHNljAoiENA0IBMESR9EAMBR0DtJxQA8DIoCuSVnAIoobFAzVJckgxQWgDhgwiIKBRIwEViEqEikBRY0ABhQEWcA66wGPBjzUBVOAMBAA7")
end


