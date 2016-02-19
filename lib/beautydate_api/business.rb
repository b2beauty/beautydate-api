module BeautydateApi
  class Business < APIResource
    def create commercial_name, type, zipcode, street, street_number, neighborhood, city, state, phone, description

      data = {
        data: {
          type: "businesses",
          attributes: {
            name: commercial_name,
            businesstype: type,
            zipcode: zipcode,
            street: street,
            street_number: street_number,
            neighborhood: neighborhood,
            city: city,
            state: state,
            phone: phone,
            description: description
          }
        }
      }

      result = APIRequest.request("POST", "#{self.class.endpoint_url}", data)
      self.errors = nil
      true
    rescue BeautydateApi::RequestWithErrors => ex
      self.errors = ex.errors
      false
    end
  end
end