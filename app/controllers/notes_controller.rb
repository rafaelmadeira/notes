class NotesController < ApplicationController
  before_action :set_note, only: %i[ show edit update destroy ]
  before_action :set_notes, only: %i[ index ]

  # GET /notes or /notes.json
  def index
    base_query = if params[:q].present?
      Note.where("content ILIKE ?", "%#{params[:q]}%")
    elsif params[:tag]
      Note.where("content LIKE ?", "%##{params[:tag]}%")
    elsif params[:referencing]
      Note.referencing(params[:referencing])
    else
      Note.all
    end

    @notes = base_query.order(created_at: :desc)
    @note = Note.new
  end

  def starred
    @notes = Note.where(starred: true).order(created_at: :desc)
    @note = Note.new
    render :index
  end

  def toggle_star
    @note = Note.find(params[:id])
    @note.update(starred: !@note.starred)
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: notes_path) }
    end
  end

  # GET /notes/1 or /notes/1.json
  def show
  end

  # GET /notes/new
  def new
    @note = Note.new
  end

  # GET /notes/1/edit
  def edit
  end

  # POST /notes or /notes.json
  def create
    @note = Note.new(note_params)

    respond_to do |format|
      if @note.save
        format.html { redirect_to notes_path, notice: "Note was successfully created." }
        format.json { render :show, status: :created, location: @note }
      else
        @notes = Note.all
        format.html { render :index, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notes/1 or /notes/1.json
  def update
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: "Note was successfully updated." }
        format.json { render :show, status: :ok, location: @note }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1 or /notes/1.json
  def destroy
    @note.destroy!

    respond_to do |format|
      format.html { redirect_to notes_path, status: :see_other, notice: "Note was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params.expect(:id))
    end

    def set_notes
      @notes = Note.all
    end

    # Only allow a list of trusted parameters through.
    def note_params
      params.require(:note).permit(:content, :starred)
    end
end
