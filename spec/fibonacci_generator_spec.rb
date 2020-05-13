RSpec.describe FibonacciEnumerator do
  let(:fiberator) { FibonacciEnumerator.from(3) }

  it 'initializes with a starting index' do
    expect(FibonacciEnumerator.from(3)).to respond_to :next
  end

  it 'no point in having #new around anymore' do
    expect(FibonacciEnumerator).not_to respond_to :new
  end

  it 'from index 3, generates increasingly increasing integers' do
    first  = fiberator.next
    second = fiberator.next
    third  = fiberator.next
    expect(first).to be < second
    expect(second).to be < third
    expect(second - first).to be < (third - second)
  end

  it 'might as well save the fib hash to a class var for reuse' do
    fiberator.next
    expect(FibonacciEnumerator.class_variables).to include :@@fibs
  end
end

