#encoding: UTF-8
require 'rest_client'
require 'base64'
require 'json'

module BeautydateApi
  module Core
    class Request
      class << self
        def consumer
          @consumer ||= BeautydateApi::Core::Consumer.new
          unless @consumer.valid?
            @consumer.authenticate(BeautydateApi.api_key)
          end
          @consumer
        rescue BeautydateApi::ObjectNotFound => e
          raise BeautydateApi::AuthenticationException, 'Não foi possível autenticar o Consumer, verifique o BEAUTYDATE_TOKEN'
        end

        def session
          @session ||= BeautydateApi::Core::Session.new(BeautydateApi.api_session_token)
          unless @session.valid?
            @session.authenticate(
              consumer.bearer,
              BeautydateApi.api_email,
              BeautydateApi.api_password
            )
          end
          @session
        rescue BeautydateApi::ObjectNotFound => e
          raise BeautydateApi::AuthenticationException, 'Não foi possível autenticar a sessão, verifique o email e senha'
        end

        def request(method, url, params: {}, payload: {})
          handle_response send_request(method, url, params, payload)
        end

        private

        def send_request(method, url, params, payload)
          RestClient::Request.execute(build_request(method, url, params, payload))
        rescue RestClient::ResourceNotFound
          raise ObjectNotFound
        rescue RestClient::UnprocessableEntity => e
          raise RequestWithErrors.new JSON.parse(e.response)
        rescue RestClient::BadRequest => e
          raise RequestWithErrors.new JSON.parse(e.response)
        end

        def handle_response(response)
          JSON.parse(response.body)
        rescue JSON::ParserError
          raise RequestFailed
        end

        def build_request(method, url, params, payload)
          {
            method: method,
            url: url,
            headers: headers.merge(params: params),
            payload: payload.to_json,
            timeout: 30
          }
        end

        def headers
          {
            user_agent: "BeautyDate/#{BeautydateApi::VERSION}; Ruby Client",
            content_type: 'application/vnd.api+json',
            authorization: self.consumer.bearer,
            'X-BeautyDate-Session-Token' => self.session.token
          }
        end
      end
    end
  end
end
