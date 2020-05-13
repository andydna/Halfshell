class FibonacciEnumerator < Enumerator
  private_class_method :new

  def self.from(index)
    new do |yielder|
      stepper = (index..).step
      @@fibs = Hash.new{ |h,k| h[k] = k < 2 ? k : h[k-1] + h[k-2] } # https://stackoverflow.com/questions/6418524/fibonacci-one-liner
      loop { yielder << @@fibs[stepper.next ] }
    end
  end
end
