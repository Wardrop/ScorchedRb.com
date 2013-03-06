require 'bundler/setup'
Bundler.require(:default)
require_relative 'lib/string'

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
          '/about' => {name: 'About'}
        }
        
        # Dynamic generation of navigation hiearchy. Only nodes corresponding to the request URL are generated.
        base_dir = 'pages'
        paths = request.path_info.gsub(%r{^/|/$}, '').split('/').reduce([]) { |m,v|
          m << (m.last ? [m.last, v].join('/') : v)
        }.map { |v| v.insert(0, '/') }
        unless paths.empty?
          paths.inject(@navigation[paths.first][:children] = {}) do |memo,path|
            memo = memo[path][:children] = {} unless memo.empty?
            if Dir.exists? File.join(base_dir, path)
              Dir.entries(File.join(base_dir, path)).reject{ |v| ['.', '..', 'index.md'].include? v}.each do |f|
                f.sub!(%r{\..+$}, '')
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
        index_files = Dir.glob(File.join(path, 'index.*'))
        if index_files.empty?
          files = Dir.glob(File.join(path, '*.*'))
          if files.empty?
            render "<em>No pages exist under: #{page}</em>"
          else
            redirect [page, File.basename(files[0].sub(%r{\..+}, ''))].join('/')
          end
        else
          render File.join('../', index_files[0]).to_sym
        end
      else
        files = Dir.glob(path + '.*')
        unless files.empty?
          render File.join('../', files[0]).to_sym
        end
      end
      
      p view

      response.status = 404 unless view
      view
    end
    
    after do
      if response.status == 404
        response.body = [] << render(:'404')
      end
    end
    
  end
end