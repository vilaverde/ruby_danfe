module RubyDanfe
  class XML
    attr_accessor :ns

    def css(xpath, no_ns = false)
      nodes = xpath.split("/")
      current = @xml

      nodes.each do |node|
        if (@ns.nil? || no_ns)
          current = current&.css(node)
        else
          current = current&.css("ns|#{ node }", :ns => @ns)
        end
      end

      current
    end

    def xpath(regex)
      doc = Nokogiri::HTML(@xml.to_s)
      return doc.xpath(regex)
    end

    def regex_string(search_string, regex)
      doc = Nokogiri::HTML(search_string)
      return doc.xpath(regex)
    end

    def initialize(xml)
      @xml = Nokogiri::XML(xml)
    end

    def [](xpath)
      node = css(xpath, true)
      node = css(xpath) unless !(node.nil? || node.empty?)

      return node ? node.text : ""
    end

    def render
      if @xml.at_css('infNFe/ide')
        RubyDanfe.render @xml.to_s, :danfe
      elsif @xml.at_css('InfNfse/Numero')
        RubyDanfe.render @xml.to_s, :danfse
      elsif @xml.at_css("ns|CTeOS", :ns => "http://www.portalfiscal.inf.br/cte")
        RubyDanfe.render @xml.to_s, :dacteos
      elsif @xml.at_css("ns|CTe", :ns => "http://www.portalfiscal.inf.br/cte")
        RubyDanfe.render @xml.to_s, :dacte
      else
        RubyDanfe.render @xml.to_s, :damdfe
      end
    end

    def collect(ns, tag, &block)
      result = []
      # Tenta primeiro com uso de namespace
      begin
        @xml.xpath("//#{ns}:#{tag}").each do |det|
          result << yield(det)
        end
      rescue
        # Caso dê erro, tenta sem
        @xml.xpath("//#{tag}").each do |det|
          result << yield(det)
        end
      end
      result
    end

    def inject(ns, tag, acc, &block)
      # Tenta primeiro com uso de namespace
      begin
        @xml.xpath("//#{ns}:#{tag}").each do |det|
          acc = yield(acc, det)
        end
      rescue
        # Caso dê erro, tenta sem
        @xml.xpath("//#{tag}").each do |det|
          acc = yield(acc, det)
        end
      end
      acc
    end

    def attr(node, attribute)
      begin
        @xml.css("ns|#{ node }", :ns => @ns)&.attr(attribute)&.text
      rescue
        ""
      end
    end
  end
end
