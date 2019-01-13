# frozen_string_literal: true

require 'fileutils'

# Represents collection of Pokemon graphical assets
class AssetManager
  ASSET_DIRS = [
    'PogoAssets/pokemon_icons',
    'PogoAssets/static_assets/png',
    'pokemon-svg/out/',
  ]

  def initialize(target_dir)
    @target_dir = target_dir
    @sources = []
    @assets = {}
  end

  def add(filename, path)
    @assets[filename] = path
  end

  def make_img_src(filenames)
    ASSET_DIRS.each do |dir|
      Array(filenames).each do |filename|
        path = File.join(dir, filename)
        if File.exist?(path)
          add(filename, path)
          return "<img src=\"#{filename}\">"
        end
      end
    end
    ''
  end

  def collect_assets
    puts "Collecting assets"
    FileUtils.mkpath(@target_dir)
    @assets.keys.sort.each do |file|
      destination = File.join(@target_dir, file)
      FileUtils.copy_file(@assets[file], destination)
    end
  end
end