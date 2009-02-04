require 'erb'

class FulltextSearchCache
  module EntityContentCache
    def to_cache
      ERB.new(<<-HTML).result(binding)
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>#{ERB::Util.h(title)}</title>
  </head>
  <body>
    #{ERB::Util.h(body)}
  </body>
</html>
HTML
    end
  end
end

