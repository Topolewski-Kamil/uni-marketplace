SimpleForm.setup do |config|
  config.wrappers :input_group, tag: 'div', class: 'form-group', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label
    b.wrapper :input_group_tag, tag: 'div', class: 'input-group' do |ba|
      ba.optional :prepend
      ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      ba.optional :append
    end
    b.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
    b.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
  end
end
