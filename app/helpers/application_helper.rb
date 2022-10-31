module ApplicationHelper
  def nav_link_to(current_identifier, *args, &block)
    arg_id = block_given? ? 1 : 2
    identifier = args[arg_id].delete(:identifier)
    args[arg_id][:class] ||= ''
    args[arg_id][:class]   = (args[arg_id][:class].split(' ') << 'nav-link').join(' ')
    content_tag :li, class: "nav-item #{'active' if identifier == current_identifier}" do
      link_to(*args, &block)
    end
  end

  def navbar_link_to(*args, &block)
    nav_link_to(@current_nav_identifier, *args, &block)
  end

  def subnav_link_to(*args, &block)
    nav_link_to(@current_subnav_identifier, *args, &block)
  end

  def no_record_tr(colspan, text = 'No records to display')
    content_tag(:tr, content_tag(:td, text, colspan: colspan, class: 'text-center text-muted' ), class: 'tr-no-record')
  end

  def partial_exist?(partial_name, prefixes = lookup_context.prefixes)
    lookup_context.exists?(partial_name, prefixes, true)
  end

end
