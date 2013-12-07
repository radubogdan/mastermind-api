class Game < ActiveRecord::Base
  attr_accessible :tries, :number

  def generate_output(number, guess)
    number_list = number.scan(/\d/).map { |n| n.to_i }
    guess_list = guess.scan(/\d/).map { |n| n.to_i }
    centered_list = []

    for i in 0..3
      centered_list.push(number_list[i] - guess_list[i])
    end

    bulls = centered_list.count(0)
    cows = (number_list & guess_list).count - bulls

    return bulls, cows
  end

  def generate_number
    begin
      number = rand(1023..9876)
    end until has_unique_digits?(number.to_s)
    self.number = number
  end

  def validations(number)
    has_unique_digits?(number) && is_number?(number) && start_with_zero?(number)
  end

  def is_number?(number)
    Float(number) != nil rescue false
  end

  def has_unique_digits?(number)
    number.length == number.split('').to_set.length
  end

  def start_with_zero?(number)
    number[0] != "0"
  end

end
