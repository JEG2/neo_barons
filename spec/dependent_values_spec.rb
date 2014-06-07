require_relative "spec_helper"

require_relative "../lib/neo_barons/dependent_values"

describe NeoBarons::DependentValues do
  it "sets and retrieves values" do
    subject.value = 42
    expect(subject.value).to eq(42)
  end

  it "accepts a block to generate a value as need" do
    subject.value { 42 }
    expect(subject.value).to eq(42)
  end

  context "generated values" do
    before :each do
      i = 0
      subject.value { i += 1 }
    end

    it "are reused" do
      expect(subject.value).to eq(subject.value)
    end

    it "can be unset and regenerated" do
      old           = subject.value
      subject.value = nil
      expect(subject.value).not_to eq(old)
    end
  end

  context "dependent values" do
    before :each do
      subject.parent = 1
    end

    it "are unset with the parent value" do
      subject.child { subject.parent ** 2 }
      old_child      = subject.child
      subject.parent = 2
      expect(subject.child).not_to eq(old_child)
    end

    it "can have multiple parents" do
      subject.other_parent = 10
      subject.child { subject.parent + subject.other_parent }
      expect(subject.child).to eq(subject.parent + subject.other_parent)

      old_child      = subject.child
      subject.parent = 2
      expect(subject.child).not_to eq(old_child)
      expect(subject.child).to     eq(subject.parent + subject.other_parent)

      old_child            = subject.child
      subject.other_parent = 20
      expect(subject.child).not_to eq(old_child)
      expect(subject.child).to     eq(subject.parent + subject.other_parent)
    end

    it "do nest" do
      subject.child      { subject.parent ** 2 }
      subject.grandchild { subject.child  ** 2 }
      old_grandchild = subject.grandchild
      old_child      = subject.child
      old_parent     = subject.parent
      subject.child  = subject.parent.succ
      expect(subject.grandchild).not_to eq(old_grandchild)
      expect(subject.child).not_to      eq(old_child)
      expect(subject.parent).to         eq(old_parent)

      old_grandchild = subject.grandchild
      old_child      = subject.child
      old_parent     = subject.parent
      subject.parent = 2
      expect(subject.grandchild).not_to eq(old_grandchild)
      expect(subject.child).not_to      eq(old_child)
      expect(subject.parent).not_to     eq(old_parent)
    end
  end
end
