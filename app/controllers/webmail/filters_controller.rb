class Webmail::FiltersController < ApplicationController
  include Webmail::BaseFilter
  include Sns::CrudFilter
  include Webmail::ImapFilter

  model Webmail::Filter

  before_action :set_imap, only: [:apply]
  after_action :unset_imap, only: [:apply]

  private
    def set_crumbs
      @crumbs << [:'mongoid.models.webmail/filter', { action: :index } ]
    end

    def fix_params
      { cur_user: @cur_user }
    end

  public
    def index
      @items = @model.
        user(@cur_user).
        search(params[:s]).
        page(params[:page]).
        per(50)
    end

    def apply
      mailbox = params[:mailbox].presence
      location = { action: :show }
      return redirect_to(location) if mailbox.blank?

      set_item
      count = @item.apply(mailbox)

      respond_to do |format|
        format.html { redirect_to location, notice: t('webmail.notice.multiple.filtered', count: count) }
        format.json { head :no_content }
      end
    end
end
