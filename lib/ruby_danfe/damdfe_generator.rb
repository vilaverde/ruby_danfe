# coding: utf-8
module RubyDanfe
  class DamdfeGenerator
    include Prawn::View

    attr_reader :xml

    def initialize(xml)
      @xml = xml
      @xml.ns = "http://www.portalfiscal.inf.br/mdfe"
    end

    def generatePDF
      init

      document.repeat :all do
        render_block1
        render_block2
        render_block3
        render_block4
        render_block5
        render_ide_table
        render_modal_table
        render_block9
        render_block10_11
        render_block15
        render_block16
        render_block17_18
        render_block19
        render_footer_table
      end

      document
    end

    private

    attr_accessor :gap, :qtd, :peso, :ciot

    def init
      @document = Prawn::Document.new(page_size: "A4", :margin => 8.mm)
      @gap = 1.5.mm
      @qtd = 31.mm
      @peso = 25.mm
      @ciot = 76.mm
    end

    def add_barcode
      nums_stripped = @xml.attr('infMDFe', 'Id')[4..-1]
      barby = Barby::PrawnOutputter.new(Barby::Code128C.new(nums_stripped))
      barby.annotate_pdf(
        self,
        margin: gap,
        x: bounds.right / 2 - barby.width / 2
      )
    end

    def render_block1
      block1 = cursor
      bounding_box([0, block1], :width => bounds.right) do
        indent(gap) do
          font_size 10  do
            move_down gap
            text @xml["emit/xFant"].upcase, align: :center, size: 12
            move_down gap
            text @xml["emit/xNome"].upcase, align: :center
            move_down gap
            text [@xml["emit/enderEmit/xLgr"], @xml["emit/enderEmit/nro"]].join(", ").upcase, align: :center
            text @xml["emit/enderEmit/xCpl"].upcase, align: :center
            text [@xml["emit/enderEmit/xBairro"], @xml["emit/enderEmit/xMun"], @xml["emit/enderEmit/UF"]].join(", ").upcase, align: :center
            text ["CEP: #{ @xml["emit/enderEmit/CEP"] }", "FONE: #{ @xml["emit/enderEmit/fone"] }"].join(", ").upcase, align: :center
            text ["CNPJ: #{ @xml["emit/CNPJ"] }", "IE: #{ @xml["emit/IE"] }"].join(", ").upcase, align: :center
          end
        end

        stroke_bounds
      end

      move_down 1.mm
    end

    def render_block2
      block2 = cursor

      bounding_box([0, block2], :width => bounds.right) do
        move_down gap
        text "DAMDFE - Documento Auxiliar de Manifesto Eletrônico de Documentos Fiscais", align: :center, size: 12

        stroke_bounds
      end

      move_down 1.mm
    end

    def render_block3
      block3 = cursor

      bounding_box([0, block3], :width => bounds.right, height: 24.mm) do
        move_down gap
        text "CONTROLE DO FISCO", align: :center, size: 8

        add_barcode

        stroke_bounds
      end
    end

    def render_block4
      block4 = cursor

      bounding_box([0, block4], :width => bounds.right) do
        move_down gap
        text "CHAVE DE ACESSO", align: :center, size: 8
        move_down gap
        text @xml.attr('infMDFe', 'Id')[4..-1], align: :center, size: 12

        stroke_bounds
      end
    end

    def render_block5
      block5 = cursor

      bounding_box([0, block5], :width => bounds.right) do
        move_down gap
        text "PROTOCOLO DE AUTORIZAÇÃO DE USO", align: :center, size: 8
        move_down gap
        text [@xml["protMDFe/infProt/nProt"], @xml["protMDFe/infProt/dhRecbto"].to_datetime.strftime('%d/%m/%Y %H:%M:%S')].join(" "), align: :center, size: 12

        stroke_bounds
      end

      move_down 1.mm
    end

    def render_ide_table
      ide_data = [
        ["Modelo", "Série", "Número", "Folha", "Data e Hora de Emissão", "UF Carreg.", "UF Descar."],
        [@xml["ide/mod"], @xml["ide/serie"], @xml["ide/mod"], "#{ page_number } / #{ page_count }", @xml["ide/dhEmi"].to_datetime.strftime('%d/%m/%Y %H:%M:%S'), @xml["ide/UFIni"], @xml["ide/UFFim"]]
      ]

      table(ide_data, width: bounds.right) do |t|
        t.rows(0).borders = [:top, :left, :right]
        t.rows(0).size = 8
        t.rows(1).borders = [:bottom, :left, :right]
        t.rows(1).size = 10
        t.cells.padding = 1
        t.cells.align = :center
      end

      move_down 1.mm
    end

    def render_modal_table
      modal_qtd_cte = @xml["qCTe"].empty? ? 0 : @xml["qCTe"]
      modal_qtd_nfe = @xml["qNFe"].empty? ? 0 : @xml["qNFe"]
      modal_qtd_mdfe = @xml["qMDFe"].empty? ? 0 : @xml["qMDFe"]
      multiplier = @xml["cUnid"].empty? ? 1 : (@xml["cUnid"].to_i == 1 ? 1 : 1000)
      modal_peso = (@xml["qCarga"].empty? ? 0 : @xml["qCarga"]).to_i * multiplier

      modal_data = [
        [{:content => "MODAL RODOVIÁRIO DE CARGA", :colspan => 5}],
        ["Qtd. CT-e", "Qtd. NF-e", "Qtd. MDF-e", "Peso (Kg)", nil],
        [modal_qtd_cte, modal_qtd_nfe, modal_qtd_mdfe, modal_peso, nil]
      ]

      table(modal_data, width: bounds.right) do |t|
        t.rows(1).borders = [:top, :left, :right]
        t.rows(1).size = 8
        t.rows(2).borders = [:bottom, :left, :right]
        t.rows(2).size = 12
        t.cells.padding = 1
        t.cells.align = :center
      end
    end

    def render_block9
      block9 = cursor

      bounding_box([0, block9], :width => qtd * 3) do
        move_down gap
        text "VEÍCULO", align: :center, size: 8
        stroke_bounds
      end

      bounding_box([qtd * 3, block9], :width => peso + ciot) do
        move_down gap
        text "CONDUTOR", align: :center, size: 8
        stroke_bounds
      end
    end

    def render_block10_11
      block10 = cursor

      bounding_box([0, block10], :width => qtd) do
        move_down gap
        text "Placa", align: :center, size: 8

        stroke_bounds
      end

      block11 = cursor

      placa = @xml["infModal/rodo/veicTracao/placa"]
      bounding_box([0, block11], :width => qtd, height: 35.mm) do
        move_down gap
        text placa, align: :center, size: 8
        @xml.css("infModal/rodo/veicReboque").each do |reboque|
          text reboque&.at_css("ns|placa", :ns => @xml.ns)&.text, align: :center, size: 8
        end

        stroke_bounds
      end

      bounding_box([qtd, block10], :width => qtd) do
        move_down gap
        text "RENAVAM", align: :center, size: 8

        stroke_bounds
      end

      renavam = @xml["infModal/rodo/veicTracao/renavam"]
      bounding_box([qtd, block11], :width => qtd, height: 35.mm) do
        move_down gap
        text renavam, align: :center, size: 8
        @xml.css("infModal/rodo/veicReboque").each do |reboque|
          text reboque&.at_css("ns|renavam", :ns => @xml.ns)&.text, align: :center, size: 8
        end

        stroke_bounds
      end

      bounding_box([qtd * 2, block10], :width => qtd) do
        move_down gap
        text "RNTRC", align: :center, size: 8

        stroke_bounds
      end

      rntrc_tracao = @xml["infModal/rodo/veicTracao/prop"] != "" ? @xml["infModal/rodo/veicTracao/prop/RNTRC"] : @xml["infModal/rodo/infANTT/RNTRC"]

      bounding_box([qtd * 2, block11], :width => qtd, height: 35.mm) do
        move_down gap
        text rntrc_tracao, align: :center, size: 8
        @xml.css("infModal/rodo/veicReboque").each do |reboque|
          rntrc_reboque = !reboque&.css("ns|prop", :ns => @xml.ns).empty? ? reboque&.at_css("ns|prop", :ns => @xml.ns)&.at_css("ns|RNTRC", :ns => @xml.ns)&.text : @xml["infModal/rodo/infANTT/RNTRC"]
          text rntrc_reboque, align: :center, size: 8
        end

        stroke_bounds
      end

      bounding_box([qtd * 3, block10], :width => peso) do
        move_down gap
        text "CPF", align: :center, size: 8

        stroke_bounds
      end

      bounding_box([qtd * 3 + peso, block10], :width => ciot) do
        move_down gap
        text "Nome", align: :center, size: 8

        stroke_bounds
      end

      bounding_box([qtd * 3, block11], :width => peso, height: 35.mm) do
        move_down gap
        indent(gap) do
          font_size 8  do
            @xml.css("infModal/rodo/veicTracao/condutor").each do |driver|
              text driver&.at_css("ns|CPF", :ns => @xml.ns)&.text, align: :left, size: 8
            end
          end
        end

        stroke_bounds
      end

      bounding_box([qtd * 3 + peso, block11], :width => ciot, height: 35.mm) do
        move_down gap
        indent(gap) do
          font_size 8  do
            @xml.css("infModal/rodo/veicTracao/condutor").each do |driver|
              text driver&.at_css("ns|xNome", :ns => @xml.ns)&.text, align: :left, size: 8
            end
          end
        end
        stroke_bounds
      end

      move_down 1.mm
    end

    def render_block15
      block15 = cursor

      bounding_box([0, block15], :width => bounds.right, height: 30.mm) do
        move_down gap
        indent(gap) do
          font_size 8  do
            text "Observação"
            move_down gap
            text @xml["infAdic/infCpl"]
          end
        end


        stroke_bounds
      end

      move_down 1.mm
    end

    def render_block16
      block16 = cursor

      bounding_box([0, block16], :width => bounds.right) do
        move_down gap
        text "INFORMAÇÕES DE SEGURO", align: :center, size: 8

        stroke_bounds
      end
    end

    def render_block17_18
      block17 = cursor
      one_third = bounds.right / 3

      bounding_box([0, block17], :width => one_third) do
        move_down gap
        text "Seguradora", align: :center, size: 8

        stroke_bounds
      end

      block18 = cursor

      bounding_box([0, block18], :width => one_third) do
        move_down gap
        indent(gap) do
          @xml.css("seg").each do |seg|
            text seg&.at_css("ns|infSeg", :ns => @xml.ns)&.at_css("ns|xSeg", :ns => @xml.ns)&.text, align: :left, size: 8
          end
        end

        stroke_bounds
      end

      bounding_box([one_third, block17], :width => one_third) do
        move_down gap
        text "Nº. da Apólice", align: :center, size: 8

        stroke_bounds
      end

      bounding_box([one_third, block18], :width => one_third) do
        move_down gap
        indent(gap) do
          @xml.css("seg").each do |apol|
            text apol&.at_css("ns|nApol", :ns => @xml.ns)&.text, align: :left, size: 8
          end
        end

        stroke_bounds
      end

      bounding_box([one_third * 2, block17], :width => one_third) do
        move_down gap
        text "Nº. da Averbação", align: :center, size: 8

        stroke_bounds
      end

      bounding_box([one_third * 2, block18], :width => one_third) do
        move_down gap
        indent(gap) do
          @xml.css("seg").each do |seg|
            text seg&.at_css("ns|nAver", :ns => @xml.ns)&.text, align: :left, size: 8
          end
        end

        stroke_bounds
      end

      move_down 1.mm
    end

    def render_block19
      block19 = cursor

      bounding_box([0, block19], :width => bounds.right) do
        move_down gap
        text "DOCUMENTOS FISCAIS VINCULADOS", align: :center, size: 8

        stroke_bounds
      end
    end

    def render_footer_table
      ctes = xml.css("chCTe").map(&:text)

      while ctes.present? do
        cell_1 = make_cell(:content => ctes&.shift&.gsub(/\d{4}/, ' \0').strip.ljust(54, " "))
        cell_2 = make_cell(:content => (ctes&.shift&.gsub(/\d{4}/, ' \0') || "").strip.ljust(54, " "))

        table([
          [cell_1, cell_2]], width: bounds.right,
          :cell_style => { :size => 8, :text_color => "000000", :padding => [1.mm,1.mm,1.mm,1.mm], align: :center })
      end
    end
  end
end
