# frozen_string_literal: true
require "spec_helper"
require "dry/request_handler/page_handler"
describe Dry::RequestHandler::PageHandler do
  shared_examples "uses the right values for page and size" do
    it "uses the value from the params if its within the limits" do
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect(handler.run).to eq(output)
    end
  end
  shared_examples "handles invalid inputs correctly" do
    it "raises the an Dry::RequestHandler::InvalidArgumentErrorerror for an invalid input" do
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect { handler.run }.to raise_error(Dry::RequestHandler::InvalidArgumentError)
    end
  end

  let(:config) do
    Confstruct::Configuration.new do
      page do
        default_size 15
        max_size 50

        posts do
          default_size 30
          max_size 50
        end

        users do
          default_size 20
          max_size 40
        end
      end
    end
  end
  # reads the size from the params if it is below the limit
  it_behaves_like "uses the right values for page and size" do
    let(:params) do
      {
        "page" => {
          "posts_size"   => "34",
          "posts_number" => "2",
          "users_size"   => "25",
          "users_number" => "2"
        }
      }
    end
    let(:output) do
      {
        number:       1,
        size:         15,
        posts_number: 2,
        posts_size:   34,
        users_number: 2,
        users_size:   25
      }
    end
  end

  # sets the size to the limit if the param requests a size bigger than allowed
  it_behaves_like "uses the right values for page and size" do
    let(:params) do
      {
        "page" => {
          "posts_size"   => "34",
          "posts_number" => "2",
          "users_size"   => "100",
          "users_number" => "2"
        }
      }
    end
    let(:output) do
      {
        number:       1,
        size:         15,
        posts_number: 2,
        posts_size:   34,
        users_number: 2,
        users_size:   40
      }
    end
  end

  # defaults to the default if it is not configured in the params
  it_behaves_like "uses the right values for page and size" do
    let(:params) do
      { "page" => {
        "users_size"   => "39",
        "users_number" => "2"
      } }
    end
    let(:output) do
      { number:       1,
        size:         15,
        posts_number: 1,
        posts_size:   30,
        users_number: 2,
        users_size:   39 }
    end
  end

  # raises an Dry::RequestHandler::InvalidArgumentError if a number is set to a non integer string
  it_behaves_like "handles invalid inputs correctly" do
    let(:params) do
      { "page" => {
        "users_size"   => "40",
        "users_number" => "asdf"
      } }
    end
  end

  # raises an Dry::RequestHandler::InvalidArgumentError if a number is set to a negative string
  it_behaves_like "handles invalid inputs correctly" do
    let(:params) do
      { "page" => {
        "users_size"   => "40",
        "users_number" => "-20"
      } }
    end
  end

  # raises an Dry::RequestHandler::InvalidArgumentError if a size is set to a negative string
  it_behaves_like "handles invalid inputs correctly" do
    let(:params) do
      { "page" => {
        "users_size"   => "-40",
        "users_number" => "20"
      } }
    end
  end

  it_behaves_like "handles invalid inputs correctly" do
    let(:params) do
      { "page" => {
        "users_size"   => "asdf",
        "users_number" => "2"
      } }
    end
  end

  it "raises an error if page config is set to nil" do
    expect { described_class.new(params: {}, page_config: nil) }
      .to raise_error(Dry::RequestHandler::MissingArgumentError)
  end

  it "raises an error if params is set to nil" do
    expect { described_class.new(params: nil, page_config: {}) }
      .to raise_error(Dry::RequestHandler::MissingArgumentError)
  end



  context "config with missing settings" do
    let(:config) do
      Confstruct::Configuration.new do
        page do
          default_size 15
          max_size 50

          posts do
            default_size 30
          end
          comments do
          end
        end
      end
    end

    # client sends the config options that are not set on the server
    it_behaves_like "uses the right values for page and size" do
      let(:params) do
        {
          "page" => {
            "posts_size"      => "34",
            "posts_number"    => "2",
            "comments_size"   => "200",
            "comments_number" => "10"
          }
        }
      end
      let(:output) do
        {
          number:          1,
          size:            15,
          posts_number:    2,
          posts_size:      34,
          comments_size:   200,
          comments_number: 10
        }
      end
    end

    it "prints a warning if the max size is not set" do
      config = Confstruct::Configuration.new do
        page do
          default_size 15
          max_size 50
          posts do
            default_size 30
          end
        end
      end
      params = {
        "page" => {
          "posts_size"   => "500",
          "posts_number" => "2"
        }
      }
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect(Dry::RequestHandler.configuration.logger).to receive(:warn).with("posts max_size config not set")
      handler.run
    end

    it "prints a warning if the default size is not set" do
      config = Confstruct::Configuration.new do
        page do
          default_size 15
          max_size 50
          posts do
            max_size 30
          end
        end
      end
      params = {
        "page" => {
          "posts_size"   => "500",
          "posts_number" => "2"
        }
      }
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect(Dry::RequestHandler.configuration.logger).to receive(:warn).with("posts default_size config not set")
      handler.run
    end

    it "prints warnings if both sized are not set" do
      config = Confstruct::Configuration.new do
        page do
          default_size 15
          max_size 50
          posts do
          end
        end
      end
      params = {
        "page" => {
          "posts_size"   => "500",
          "posts_number" => "2"
        }
      }
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect(Dry::RequestHandler.configuration.logger).to receive(:warn).twice
      handler.run
    end

    it "prints warnings if both sized are not set" do
      config = Confstruct::Configuration.new do
        page do
          default_size 15
          max_size 50
        end
      end
      params = {
        "page" => {
          "foo_size" => "3"
        }
      }
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect(Dry::RequestHandler.configuration.logger).to receive(:warn).with("client sent unknown option foo_size")
      handler.run
    end

    it "raises an error if there is no way to determine the size of an option" do
      params = {
        "page" => {
          "posts_size"   => "34",
          "posts_number" => "2"
        }
      }
      handler = Dry::RequestHandler::PageHandler.new(params: params, page_config: config.lookup!("page"))
      expect { handler.run }.to raise_error(Dry::RequestHandler::NoConfigAvailableError)
    end
  end
end
