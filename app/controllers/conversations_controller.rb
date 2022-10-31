class ConversationsController < ApplicationController
  
  before_action :set_conversation, only: [:show, :edit, :update, :destroy]

  # GET /conversations
  def index
    @conversations = Conversation.where(buyer: current_user).or(Conversation.where(seller: current_user)).order(updated_at: :desc)
  end

  # GET /conversations/1
  def show
    @conversations = Conversation.where(buyer: current_user).or(Conversation.where(seller: current_user)).order(updated_at: :desc)
    @messages = Message.where(conversation: @conversation).order(updated_at: :asc)
    @message = Message.new
  end

  # GET /conversations/new
  def new
    @conversation = Conversation.new
  end

  # GET /conversations/1/edit
  def edit
  end

  # POST /conversations
  def create
    @conversation = Conversation.new()

    @conversation.listing = Listing.find(params[:listing])
    @conversation.buyer =  User.find(params[:buyer])
    @conversation.seller =  User.find(params[:seller])

    if Conversation.create(buyer: @conversation.buyer, seller: @conversation.seller, listing: @conversation.listing).valid?
      new_conversation = Conversation.where(buyer: @conversation.buyer, seller:  @conversation.seller, listing: @conversation.listing)
      redirect_to '/conversations/' + new_conversation.ids[0].to_s, notice: 'Conversation was successfully created.'
    else
      duplicated_conversation = Conversation.where(buyer: @conversation.buyer, seller:  @conversation.seller, listing: @conversation.listing)
      redirect_to '/conversations/' + duplicated_conversation.ids[0].to_s
    end
  end

  # PATCH/PUT /conversations/1
  def update
    if @conversation.update(conversation_params)
      redirect_to @conversation, notice: 'Conversation was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /conversations/1
  def destroy
    @conversation.destroy
    redirect_to conversations_url, notice: 'Conversation was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_conversation
      @conversation = Conversation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def conversation_params
      params.require(:conversation).permit(:listing_id, :seller_id, :buyer_id)
    end
end
