#!/usr/bin/env ruby
# coding: utf-8

module TOKEN
  ADD = 1 # 足し算
  SUB = 1 # 引き算
  MUL = 2 # 掛け算
  DIV = 2 # 割り算
  IMD = 1000 # 値そのもの
end

module OPTION
  STR = {
    "+" => TOKEN::ADD,
    "-" => TOKEN::SUB,
    "*" => TOKEN::MUL,
    "/" => TOKEN::DIV
  }
  PROC = {
    "+" => Proc.new do |x, y| x + y end,
    "-" => Proc.new do |x, y| x - y end,
    "*" => Proc.new do |x, y| x * y end,
    "/" => Proc.new do |x, y| x / y end
  }
end

class Expr
  def initialize(val = 0)
    @val = val
  end

  def eval
    @val
  end

  def inspect
    "Expr(#{@val})"
  end
end 

class BinOpExpr < Expr
  def initialize(op, left, right)
    @op = op
    @left = left
    @right = right
  end

  def eval
    # 実行する
    OPTION::PROC[@op].call(@left.eval, @right.eval)
  end

  def inspect
    "BinOp(#{@op})\nleft=#{@left.inspect}\nright=#{@right.inspect}"
  end
end

class Tokenizer
  class Token
    attr_reader :s, :type, :priority
    def initialize(s, type)
      @s = s
      @type = type
      case @type
      when :immidiate # 値
        @priority = TOKEN::IMD
      when :operator # 演算子
        @priority = OPTION::STR[@s]
      end
    end
  end

  def initialize(tokens = [])
    @tokens = tokens
  end

  def <<(tok)
    @tokens << Token.new(tok[0], tok[1])
  end

  def [](index)
    @tokens[index]
  end

  def length
    @tokens.length
  end

  # トークン配列の中からrootになる要素（優先度min）のインデックスを返す
  # 優先度が同じトークンは後ろが勝つ
  def root
    r = @tokens.reverse.each_with_index.min_by { |t,i| t.priority }.last
    @tokens.length - r - 1
  end

  def tokenize
    return _tokenize(self)
  end

  def _tokenize(tokens)
    if tokens.length == 1
      return Expr.new(tokens[0].s.to_i)
    end
    # トークン配列の中からrootになる要素（優先度min）を探す
    r = tokens.root
    left = _tokenize(Tokenizer.new(tokens[0..r-1]))
    right = _tokenize(Tokenizer.new(tokens[r+1..tokens.length-1]))
    expr = BinOpExpr.new(tokens[r].s, left, right)
  end

  def inspect
    str = ""
    @tokens.each { |tok|
      str += "\"#{tok.s}\"\t=> #{tok.type}\t(priority: #{tok.priority})\n"
    }
    str
  end
end

# 文字解析
def parse(s)
  i = 0
  token = Tokenizer.new
  while i < s.length do
    # 整数値
    if /^\d+/ =~ s[i..s.length-1] 
      token << [$&, :immidiate]
    # スペース
    elsif /^\s+/ =~ s[i..s.length-1]
    else
      # 演算子
      OPTION::STR.each do |x|
        re = /^#{Regexp.escape("#{x[0]}")}/
        if re =~ s[i..s.length-1] 
          token << [$&, :operator]
          break
        end
      end
      
      if !$&
        raise SyntaxError, "Invalid token in `#{s}`"
      end
    end
    i += $&.length
  end
  return token
end

# mainのscript
begin
  print ">>> "
  while s = gets.chomp! do
    if s.empty?
      print ">>> "
      next
    end
    token = parse(s)
    tree = token.tokenize
    p tree.eval
    print ">>> "
  end
rescue Interrupt => e
  print "\nend\n"
rescue SyntaxError => e
  print e, "\nsyntaxError\n"
end