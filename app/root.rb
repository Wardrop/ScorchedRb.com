require 'bundler/setup'
Bundler.require(:default)
Dir.glob(File.join(__dir__, 'lib', '*.rb')) { |f| require_relative f }

module ScorchedRb
  class Root < Scorched::Controller
    # Configure ScorchedRb defaults
    if ENV['RACK_ENV'] == 'development'
      config[:static] = '../public'
    end
    view_config[:dir] = 'views'
    view_config[:layout] = :layout
    
    def pages
      return @pages if @pages
      @pages = Dir.glob('pages/**/*').map! { |v| v.sub(%r{^pages/}, '') }.reject { |v| v =~ /index.md$/}
    end
    
    def navigation
      unless @navigation
        @navigation = {
          '/' => {name: 'Home'},
          '/docs' => {name: 'Documentation'},
          'http://github.com/wardrop/Scorched' => {name: 'Code'},
          'http://github.com/wardrop/Scorched/issues' => {name: 'Tracker'},
          '/about' => {name: 'About'}
        }
        
        # Dynamic generation of navigation hiearchy. Only nodes corresponding to the request URL are generated.
        base_dir = 'pages'
        paths = request.path_info.gsub(%r{^/|/$}, '').split('/').reduce([]) { |m,v|
          m << (m.last ? [m.last, v].join('/') : v)
        }.map { |v| v.insert(0, '/') }
        unless paths.empty? || @navigation[paths.first].nil?
          paths.inject(@navigation[paths.first][:children] = {}) do |memo,path|
            memo = memo[path][:children] = {} unless memo.empty?
            if Dir.exists? File.join(base_dir, path)
              Dir.entries(File.join(base_dir, path)).shuffle.sensible_sort.reject{ |v| %w{. .. index.md}.include? v}.each do |f|
                f.sub!(%r{\..+?$}, '')
                memo[File.join(path, f)] = {name: f.snake_to_titlecase}
              end
            end
            memo
          end
        end
      end
      @navigation
    end
    
    get '/*.css' do |name|
      response['Content-Type'] = 'text/css'
      render :"#{name}.scss", layout: false
    end
    
    # Maps the accessed URL to a file under ./pages
    # If URL maps to a directory, looks for an index file. If no index fle exists, redirects browser to the first file
    # in the directory. If no files exist in the directory, a message is returned saying so.
    # If multiple files with the same name but different extensions exist, the first one returned by Dir#glob is served.
    get %r{(/.*)} do |page|
      page = page.empty? ? 'index' : page
      path = File.join('pages', page)
      view = if Dir.exists?(path)
        index_files = sorted_glob(File.join(path, 'index.*'))
        if index_files.empty?
          files = sorted_glob(File.join(path, '*.*'))
          if files.empty?
            render "<p><em>No pages exist under: #{page}</em></p>"
          else
            redirect [page, File.basename(files[0].sub(%r{\..+}, ''))].join('/')
          end
        else
          render File.join('../', index_files[0]).to_sym
        end
      else
        files = sorted_glob(path + '.*')
        unless files.empty?
          render File.join('../', files[0]).to_sym
        end
      end

      response.status = 404 unless view
      view
    end
    
    def sorted_glob(*args, &block)
      Dir.glob(*args, &block).sensible_sort!
    end
    
    after do
      if response.status == 404
        response.body = [render(:'404')]
      end
    end
    
    after do
      if response['Content-Type'].nil? || response['Content-Type'] =~ %r{^text/html}
        doc = Nokogiri::HTML(response.body.join(''))
        doc.css('code').each do |element|
          if element.inner_text =~ /^\s*#\s*ruby/
            coderay = Nokogiri::HTML::DocumentFragment.parse(
              CodeRay.scan(element.inner_text.sub(/^.+\r?\n?/, ''), :ruby).html(:wrap => :span)
            )
            element['class'] = 'CodeRay'
            element.inner_html = coderay.children[0].children.to_html
          end
        end
        response.body = [doc.to_html]
      end
    end
    
  end
end