class WordAnalyzer
  DICT_DIR = "#{Rails.root}/lib/data/dict" #TODO: privateにしたい
  @@dict_path = ["/adv.exc", "/noun.exc"].map { |file| DICT_DIR + file }
  @@lemmatizer = Lemmatizer.new(@@dict_path)
  @@tagger = EngTagger.new

  class << self
    # 英単語をlemmatizeする関数
    def lemmatize(word, pos = nil)
      @@lemmatizer.lemma(word, pos)
    end

    # 英文を品詞解析する関数(動詞と名詞のみ. それ以外はnilを返す)
    @@verbs = ["VB", "VBD", "VBG", "VBN", "VBP", "VBZ"]
    @@nouns = ["NN", "NNS", "NNP", "NNPS"]
    @@adjs = ["JJ", "JJR", "JJS"]
    @@advs = ["RB", "RBR", "RBS", "MD"]
    def part_of_speechs(sentence)
      tagged = @@tagger.get_readable(sentence.downcase).split(" ").map { |word| word.split("/") }
    end

    # 英文をlemmatizeする
    def lemmatize_sentence(sentence)
      tagged = part_of_speechs(sentence)
      
      tagged.map do |word, tag|
        pos = tag_to_pos(tag)
        # lemmatize(word, pos)
        lemmatize(word) #TODO: 一旦品詞を無視してlemmatizeしてみる
      end.join(" ")
    end

    def get_words(text, unique: true)
      words = text.scan(/\b\w+\b/)
      words.select! { |word| is_word?(word) }
      words.map!(&:downcase)
      words.uniq! if unique
      words
    end

    def get_basic_forms(text, unique: true)
      text.gsub!("\n", "")
      lemmatized = WordAnalyzer.lemmatize_sentence(text).scan(/\b\w+\b/)
      
      res = lemmatized.select { |word| is_word?(word) }
      res.uniq! if unique
      res
    end

    def is_word?(word)
      !word.match?(/['’()!,.0-9:#]/) && word.length > 0
    end

    ### lemmatizeがうまくいっているかテストする関数
    def test_lemmatize(word)
      lemmatized = lemmatize(word)
      if word == lemmatized && (lemmatized.match?(/s$/) || lemmatized.match?(/ing$/) || lemmatized.match?(/ed$/) || lemmatized.match?(/er$/) || lemmatized.match?(/est$/))
        false
      else
        true
      end
    end

    private
    
    def tag_to_pos(tag)
      case tag
      when *@@verbs
        :verb
      when *@@nouns
        :noun
      when *@@adjs
        :adj
      when *@@advs
        :adv
      else
        nil
      end
    end
  end
end
