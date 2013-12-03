class Game < ActiveRecord::Base
  attr_accessible :tries

  def generate_output(number, guess)
    number_list = number.split(',').map { |n| n.to_i }
    guess_list = guess.split(',').map { |n| n.to_i }
    result = number_list - guess_list
    return result.length
  end

  def generate_number
    begin
      number = rand(1023..9876)
    end while !has_unique_digits?(number.to_s)
    self.number = number
  end

  def has_unique_digits?(number)
    number.length == number.split('').to_set.length && is_number?(number) && number[0] != "0"
  end

  private 

  def is_number?(number)
    Float(number) != nil rescue false
  end

end
