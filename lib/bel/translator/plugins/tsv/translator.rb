# lib/bel/translator/plugins/tsv/translator.rb

module BEL::Translator::Plugins::Tsv

  class TsvTranslator

    include ::BEL::Translator
    include ::BEL::Model

    def read(data, options = {})
      data.each_line.map { |line|
        ctype, cid, support, statement = line.strip.split("\t")
        bel_nanopub = Evidence.create(
          citation:      Citation.new(type: ctype, id: cid),
          summary_text:  SummaryText.new(support),
          bel_statement: statement   
        )

        bel_nanopub.bel_statement = Evidence.parse_statement(bel_nanopub)

        bel_nanopub
      }
    end

    def write(nanopub_stream, output = StringIO.new, options = {})
      nanopub_stream.each do |evidence|
        output << (
          [
            evidence.citation.type,
            evidence.citation.id,
            evidence.summary_text.to_s.gsub("\n", ""),
            evidence.bel_statement
          ].join("\t") + "\n"
        )
      end

      output
    end
  end
end
