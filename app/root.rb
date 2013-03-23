require 'bundler/setup'
Bundler.require(:default)
Dir.glob(File.join(__dir__, 'lib', '*.rb')) { |f| require_relative f }

module ScorchedRb
  class Root < Scorched::Controller
    # Configure ScorchedRb defaults
    if ENV['RACK_ENV'] == 'development'
      config[:static] = '../public'
    end
    render_defaults[:dir] = 'views'
    render_defaults[:layout] = :layout
    render_defaults[:fenced_code_blocks] = true
    
    def navigation
      unless @navigation
        @navigation = {
          '/' => {name: 'Home'},
          '/docs' => {name: 'Documentation'},
          'http://rubydoc.info/gems/scorched' => {name: 'API'}
          'http://github.com/wardrop/Scorched' => {name: 'Code'},
          'http://github.com/wardrop/Scorched/issues' => {name: 'Tracker'},
          'https://groups.google.com/d/forum/scorched' => {name: 'Discuss'},
          '/about' => {name: 'About'}
        }
        
        # Dynamic generation of navigation hiearchy. Only nodes corresponding to the request URL are generated.
        base_dir = 'pages'
        structure = Dir.glob(File.join(base_dir, '**/*'))
        paths = request.path_info.gsub(%r{^/|/$}, '').split('/').map! { |v| "[0-9_]*#{v}" }.
          reduce([]) { |m,v| m << (m.last ? [m.last, v].join('/') : v) }.
          map! { |path|
            file = structure.select { |f| f =~ /#{File.join(base_dir, path).insert(0, "^")}/ }[0]
            {file: file, url: file.sub(%r{^#{base_dir}}, '').gsub(%r{/[0-9_]*}, '/').sub(%r{\.[^.]*$}, '')} if file
          }.compact
          
        unless paths.empty? || @navigation[paths.first[:url]].nil?
          paths.inject(@navigation[paths.first[:url]][:children] = {}) do |memo, path|
            memo = memo[path[:url]][:children] = {} unless memo.empty? || !memo[path[:url]]
            if Dir.exists? path[:file]
              Dir.entries(path[:file]).sort.reject{ |v| v =~ /^\.|^index\.[^.]*/}.each do |f|
                f = f.sub(%r{^[0-9_]*}, '').sub(%r{\.[^.]*$}, '')
                memo[File.join(path[:url], f)] = {name: f.snake_to_titlecase}
              end
            end
            memo
          end
        end
      end
      @navigation
    end
    
    # Maps the accessed URL to a file under ./pages
    # If URL maps to a directory, looks for an index file. If no index fle exists, redirects browser to the first file
    # in the directory. If no files exist in the directory, a message is returned saying so.
    # If multiple files with the same name but different extensions exist, the first one returned by Dir#glob is served.
    get %r{(/.*)} do |page|
      page = page.empty? ? 'index' : page
      path_pattern = Regexp.new File.join('pages', page).split('/').map { |v| "[0-9_]*#{v}" }.join('/').insert(0, '^')
      path = Dir.glob('pages/**/*').unshift('pages').select { |f| f =~ path_pattern }.first
      view = if path
        if Dir.exists? path
          index_files = Dir.glob(File.join(path, 'index.*')).sort
          if index_files.empty?
            files = Dir.glob(File.join(path, '*')).sort
            if files.empty?
              "<p><em>No pages exist under: #{page}</em></p>"
            else
              redirect [page, File.basename(files[0]).sub(%r{\..+}, '').sub(%r{^[0-9_]*}, '')].join('/').gsub(%r{/+}, '/')
            end
          else
            File.join('../', index_files[0]).to_sym
          end
        elsif File.exists? path
          File.join('../', path).to_sym
        end
      end
      
      if view
        @title = %r{([^/]+?)(\..*)?$}.match(page)[1].snake_to_titlecase rescue nil
        render view
      else
        response.status = 404
      end
    end
    
    after status: 404 do
      response.body = render(:'404')
    end
    
    after status: 200 do
      if response.body.respond_to?(:join) && (!response['Content-Type'] || response['Content-Type'] =~ %r{^text/html})
        doc = Nokogiri::HTML(response.body.join(''))
        doc.css('code.ruby').each do |element|
          coderay = Nokogiri::HTML::DocumentFragment.parse(
            CodeRay.scan(element.inner_text, :ruby).html(:wrap => :span)
          )
          element['class'] = 'CodeRay'
          element.inner_html = coderay.children[0].children.to_html
        end
        response.body = [doc.to_html]
      end
    end
    
  end
end