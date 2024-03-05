require 'csv'

class BlogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blog, only: %i[ show edit update destroy ]

  # GET /blogs or /blogs.json
  def index
    # @blogs = current_user.blogs
    @pagy, @blogs = pagy(current_user.blogs)
  end

  # GET /blogs/1 or /blogs/1.json
  def show
  end

  # GET /blogs/new
  def new
    @blog = current_user.blogs.new
  end

  # GET /blogs/1/edit
  def edit
  end

  # POST /blogs or /blogs.json
  def create
    @blog = current_user.blogs.new(blog_params)

    respond_to do |format|
      if @blog.save
        format.html { redirect_to blog_url(@blog), notice: "Blog was successfully created." }
        format.json { render :show, status: :created, location: @blog }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blogs/1 or /blogs/1.json
  def update
    respond_to do |format|
      if @blog.update(blog_params)
        format.html { redirect_to blog_url(@blog), notice: "Blog was successfully updated." }
        format.json { render :show, status: :ok, location: @blog }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @blog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blogs/1 or /blogs/1.json
  def destroy
    @blog.destroy

    respond_to do |format|
      format.html { redirect_to blogs_url, notice: "Blog was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # BTW most efficient and best way to import in batches in background jobs
  def import
    file = params[:attachment]
    batch_size = 1000

    csv = CSV.open(file.path, headers: true)
    csv.lazy.each_slice(batch_size) do |csv_rows|
      blogs_to_create = []

      # Build array of Blog objects
      csv_rows.each do |row|
        blog_params = row.to_h
        blog_params['user_id'] ||= current_user.id if blog_params['user_id'].nil? #if value is not in csv
        blogs_to_create << Blog.new(blog_params)
      end

      # Insert blogs in bulk
      Blog.import blogs_to_create, recursive: true
    end
    flash[:success] = "Blogs imported successfully."
  rescue => e
    flash[:error] = "An error occurred during the import: #{e.message}"
  ensure
    redirect_to blogs_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_blog
    @blog = current_user.blogs.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def blog_params
    params.require(:blog).permit(:title, :body, :user_id)
  end
end
