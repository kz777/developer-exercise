require 'rspec'

class Card

  attr_accessor :suit, :value
  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def value
    return 10 if ["J", "Q", "K"].include?(@value)
    return 11 || 1 if @value == "A"
    return @value
  end

  def to_s
    "#{@value}-#{suit}"
  end

end

class Deck
  attr_accessor :cards

  def initialize
    @cards = Deck.build_cards
  end

  def self.build_cards
    cards = []
    [:clubs, :diamonds, :spades, :hearts].each do |suit|
      (2..10).each do |number|
        cards << Card.new(suit, number)
      end
      ["J", "Q", "K", "A"].each do |facecard|
        cards << Card.new(suit, facecard)
      end
    end
    cards.shuffle
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def hit!(deck)
    @cards << deck.cards.shift
  end

  def value
    cards.inject(0) {|sum, card| sum += card.value }
  end

  def play_as_dealer(deck)
    if value < 17
      hit!(deck)
      play_as_dealer(deck)
    end
  end
end


class Game
  attr_reader :player_hand, :dealer_hand
  def initialize
    @deck = Deck.new
    @player_hand = Hand.new
    @dealer_hand = Hand.new
    2.times { @player_hand.hit!(@deck) } 
    2.times { @dealer_hand.hit!(@deck) }
  end

  def hit
    @player_hand.hit!(@deck)
  end

  def stand
    @dealer_hand.play_as_dealer(@deck)
    @winner = determine_winner(@player_hand.value, @dealer_hand.value)
  end

  def status
    {:player_cards=> @player_hand.cards, 
     :player_value => @player_hand.value,
     :dealer_cards => @dealer_hand.cards,
     :dealer_value => @dealer_hand.value,
     :winner => @winner}
  end

  def determine_winner(player_value, dealer_value)
    return :dealer if player_value > 21
    return :player if dealer_value > 21
    if player_value == dealer_value
      :push
    elsif player_value > dealer_value
      :player
    else
      :dealer
    end
  end

  def inspect
    status
  end
end


describe Card do

  it "should accept suit and value when building" do
    card = Card.new(:clubs, 10)
    expect(card.suit).to eq(:clubs)
    expect(card.value).to eq(10)
  end

  it "should have a value of 10 for facecards" do
    facecards = ["J", "Q", "K"]
    facecards.each do |facecard|
      card = Card.new(:hearts, facecard)
      expect(card.value).to eq(10)
    end
  end
  it "should have a value of 4 for the 4-clubs" do
    card = Card.new(:clubs, 4)
    expect(card.value).to eq(4)
  end

  it "should return 11 or 1 for Ace" do
    card = Card.new(:diamonds, "A")
    expect(card.value).to eq(11 || 1)
  end

  it "should be formatted nicely" do
    card = Card.new(:diamonds, "A")
    expect(card.to_s).to eq("A-diamonds")
  end

end


describe Deck do

  it "should build 52 cards" do
    Deck.build_cards.length.should eq(52)
  end

  it "should have 52 cards when new deck" do
    Deck.new.cards.length.should eq(52)
  end

end


describe Hand do

  it "should calculate the value correctly" do
    deck = double(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 10)])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    expect(hand.value).to eq(14)
  end

  it "should take from the top of the deck" do
    club4 = Card.new(:clubs, 4)
    diamond7 = Card.new(:diamonds, 7) 
    clubK = Card.new(:clubs, "K")

    deck = double(:deck, :cards => [club4, diamond7, clubK])
    hand = Hand.new
    2.times { hand.hit!(deck) }
    expect(hand.cards).to eq([club4, diamond7])

  end

  describe "#play_as_dealer" do
    it "should hit below 17" do
      deck = double(:deck, :cards => [Card.new(:clubs, 4), Card.new(:diamonds, 4), Card.new(:clubs, 2), Card.new(:hearts, 7)])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      expect(hand.value).to eq(17)
    end
    it "should not hit above 17" do
      deck = double(:deck, :cards => [Card.new(:clubs, 8), Card.new(:diamonds, "Q")])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      expect(hand.value).to eq(18)
    end
    it "should stop on 21" do
      deck = double(:deck, :cards => [Card.new(:clubs, 4), 
                                    Card.new(:diamonds, 7), 
                                    Card.new(:clubs, "K")])
      hand = Hand.new
      2.times { hand.hit!(deck) }
      hand.play_as_dealer(deck)
      expect(hand.value).to eq(21)
    end
  end
end


describe Game do

  it "should have a players hand" do
    expect(Game.new.player_hand.cards.length).to eq(2)
  end
  it "should have a dealers hand" do
    expect(Game.new.dealer_hand.cards.length).to eq(2)
  end
  it "should have a status" do
    expect(Game.new.status).to_not be_nil
  end
  it "should hit when I tell it to" do
    game = Game.new
    game.hit
    expect(game.player_hand.cards.length).to eq(3)
  end

  it "should play the dealer hand when I stand" do
    game = Game.new
    game.stand
    expect(game.status[:winner]).to_not be_nil
  end

  describe "#determine_winner" do
    it "should have dealer win when player busts" do
      expect(Game.new.determine_winner(22, 15)).to eq(:dealer) 
    end
    it "should player win if dealer busts" do
      expect(Game.new.determine_winner(18, 22)).to eq(:player) 
    end
    it "should have player win if player > dealer" do
      expect(Game.new.determine_winner(18, 16)).to eq(:player) 
    end
    it "should have push if tie" do
      expect(Game.new.determine_winner(16, 16)).to eq(:push) 
    end
  end
end