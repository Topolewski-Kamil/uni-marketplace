class PoliciesController < ApplicationController

    before_action :get_policy, except: [:parse]
    before_action :init_parser, :get_raw
    before_action :get_raw, only: [:show, :edit]

    # covid-19 and site policies pages (/policies/:policy)
    def show
        @parsed = @markdown.render(@markdown_raw).html_safe
        render template: "policies/#{params[:page]}"
    end

    # for editing the policies with mordown editor
    def edit
        if @policy != "covid-19" && @policy != "site_policy"
            redirect_to "/404"
        end
    end

    # updates the policy file (post request to /policies/edit/:policy)
    def update
        if @policy == "covid-19" || @policy == "site_policy"
            # update file and respond with 200-ok if policy exists
            File.open("app/assets/markdown/#{@policy}.md", 'w') {|f| f.write params[:markdown]}
            respond_to do |format|
                format.html
                format.json {render status: 200, json:  {"success" => true}}
            end

        else
            # respond with error if policy doesn't exist
            respond_to do |format|
                format.html
                format.json {render status: 400, json: {"success" => false}}
            end
        end
    end

    # get processed markdown in json
    def parse
        puts 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        raw = params[:raw]
        @parsed = @markdown.render(raw).html_safe
        respond_to do |format|
            #format.html
            format.json {render status: 200, json: @parsed.to_json}
        end
    end


    private
        def init_parser
            @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
        end

        # checks which policy is accessed and 404 if invalid
        def get_policy
            @policy = params[:page]

            if @policy != "covid-19" && @policy != "site_policy"
                redirect_to "/404"
            end
        end

        # reads the markdown file
        def get_raw
            @markdown_raw = File.read("app/assets/markdown/#{@policy}.md")
        end
end