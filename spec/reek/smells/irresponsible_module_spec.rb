require 'spec_helper'
require 'reek/smells/irresponsible_module'
require 'reek/smells/smell_detector_shared'
include Reek::Smells

describe IrresponsibleModule do
  before(:each) do
    @bad_module_name = 'WrongUn'
    @detector = IrresponsibleModule.new('yoof')
  end

  it_should_behave_like 'SmellDetector'

  it 'does not report re-opened modules' do
    src = <<-EOS
      # Abstract base class
      class C; end

      class C; def foo; end; end
    EOS
    expect(src).not_to reek_of(:IrresponsibleModule)
  end

  it 'does not report a class having a comment' do
    src = <<EOS
# test class
class Responsible; end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    expect(@detector.examine_context(ctx)).to be_empty
  end
  it 'reports a class without a comment' do
    src = "class #{@bad_module_name}; end"
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    expect(smells.length).to eq(1)
    expect(smells[0].smell_class).to eq(IrresponsibleModule::SMELL_CLASS)
    expect(smells[0].subclass).to eq(IrresponsibleModule::SMELL_SUBCLASS)
    expect(smells[0].lines).to eq([1])
    expect(smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY]).to eq(@bad_module_name)
  end
  it 'reports a class with an empty comment' do
    src = <<EOS
#
#
#
class #{@bad_module_name}; end
EOS
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    expect(smells.length).to eq(1)
    expect(smells[0].smell_class).to eq(IrresponsibleModule::SMELL_CLASS)
    expect(smells[0].subclass).to eq(IrresponsibleModule::SMELL_SUBCLASS)
    expect(smells[0].lines).to eq([4])
    expect(smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY]).to eq(@bad_module_name)
  end
  it 'reports a fq module name correctly' do
    src = 'class Foo::Bar; end'
    ctx = CodeContext.new(nil, src.to_reek_source.syntax_tree)
    smells = @detector.examine_context(ctx)
    expect(smells.length).to eq(1)
    expect(smells[0].smell_class).to eq(IrresponsibleModule::SMELL_CLASS)
    expect(smells[0].subclass).to eq(IrresponsibleModule::SMELL_SUBCLASS)
    expect(smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY]).to eq('Foo::Bar')
    expect(smells[0].context).to match(/#{smells[0].smell[IrresponsibleModule::MODULE_NAME_KEY]}/)
  end
end
