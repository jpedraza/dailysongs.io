Rails.application.config.middleware.use HtmlCompressor::Rack, {
  compress_javascript: true,
  javascript_compressor: Uglifier.new,
  remove_intertag_spaces: true,
  remove_surrounding_spaces: HtmlCompressor::Compressor::BLOCK_TAGS_MIN
}
