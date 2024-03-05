module EmployeesHelper
  def render_form_field(label, attribute, value = nil, type: :text)
    content_tag :div, class: 'mb-3' do
      concat label_tag attribute, label, class: 'form-label'
      concat send("#{type}_field_tag", attribute, value, class: 'form-control')
    end
  end
end
