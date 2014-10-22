# -*- encoding: utf-8 -*-
class ClassificationsController < ApplicationController
  load_and_authorize_resource :except => [:index, :search_name]
  before_filter :get_subject, :get_classification_type
  after_filter :solr_commit, :only => [:create, :update, :destroy]

  # GET /classifications
  # GET /classifications.json
  def index
    search = Sunspot.new_search(Classification)
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
      search.build do
        fulltext query
      end
    end
    unless params[:mode] == 'add'
      subject = @subject
      classification_type = @classification_type
      search.build do
        with(:subject_ids).equal_to subject.id if subject
        with(:classification_type_id).equal_to classification_type.id if classification_type
      end
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Classification.default_per_page)
    @classifications = search.execute!.results

    session[:params] = {} unless session[:params]
    session[:params][:classification] = params

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @classifications }
    end
  end

  # GET /classifications/1
  # GET /classifications/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @classification }
    end
  end

  # GET /classifications/new
  # GET /classifications/new.json
  def new
    @classification_types = ClassificationType.all
    @classification = Classification.new
    @classification.classification_type = @classification_type

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @classification }
    end
  end

  # GET /classifications/1/edit
  def edit
    @classification_types = ClassificationType.all
  end

  # POST /classifications
  # POST /classifications.json
  def create
    @classification = Classification.new(params[:classification])

    respond_to do |format|
      if @classification.save
        format.html { redirect_to @classification, :notice => t('controller.successfully_created', :model => t('activerecord.models.classification')) }
        format.json { render :json => @classification, :status => :created, :location => @classification }
      else
        @classification_types = ClassificationType.all
        format.html { render :action => "new" }
        format.json { render :json => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classifications/1
  # PUT /classifications/1.json
  def update
    respond_to do |format|
      if @classification.update_attributes(params[:classification])
        format.html { redirect_to @classification, :notice => t('controller.successfully_updated', :model => t('activerecord.models.classification')) }
        format.json { head :no_content }
      else
        @classification_types = ClassificationType.all
        format.html { render :action => "edit" }
        format.json { render :json => @classification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classifications/1
  # DELETE /classifications/1.json
  def destroy
    @classification = Classification.find(params[:id])
    @classification.destroy

    respond_to do |format|
      format.html { redirect_to classifications_url }
      format.json { head :no_content }
    end
  end

  def get_classification_type
    @classification_type = ClassificationType.find(params[:classification_type_id]) rescue nil
  end

  def search_category
    if params[:sub_category_number]
      @category = 1 # 詳細のページを表示するかのフラグ
      sub_category_number = params[:sub_category_number]
      @count_start = ("#{sub_category_number}" + "00").to_i
      @count_end = @count_start + 99
      @step = 10
      @categories = Classification.get_detail_categories(sub_category_number, @count_start, @count_end)
    else
      @category = 0 # 詳細のページを表示するかのフラグ
      @count_start = 0
      @count_end = 900
      @step = 100
      @categories = Classification.get_sub_categories
    end
  
    @search_param = {}
    @search_param_title = {}
    @link = {}
    @link_title = {}
    if params[:sub_category_number]
      @count_start.upto(@count_end) do |index| 
        if index % 10 == 0
          @search_param_title[index] = [{"classification_identifier" => "#{index / 10}", "classification_type_id" => "2"}]
          @link_title[index] = page_advanced_search_path(:classifications => @search_param_title[index])
        end
        if SystemConfiguration.get('manifestation.search.use_select2_for_classification') 
          if @categories[index] 
            @search_param[index] = [{"classification_id" => "#{@categories[index].id}", "classification_type_id" => "#{@categories[index].classification_type_id}"}] 
          else 
            @search_param[index] = [{"classification_id" => nil, "classification_type_id" => "2"}] 
          end 
        else 
          @search_param[index] = [{"classification_identifier" => "#{sprintf("%03d",index)}", "classification_type_id" => "2"}] 
        end 
        @link[index] = page_advanced_search_path(:classifications => @search_param[index])
      end 
    else
      @count_start.step(@count_end, 10) do |index| 
        if index % 100 == 0
          @search_param_title[index] = [{"classification_identifier" => "#{index / 100}", "classification_type_id" => "2" }]
          @link_title[index] = page_advanced_search_path(:classifications => @search_param_title[index])
        end
        @search_param[index] = {:sub_category_number => index / 100, :anchor => "#{index}"}
        @link[index] = classifications_search_category_path(@search_param[index])
      end
    end

    render :layout => 'classification_search'
  end

  # GET /classifications/search_name.json
  def search_name
    struct_classification = Struct.new(:id, :text)
    if params[:classification_id]
       classification = Classification.where(id: params[:classification_id]).select("id, category, classification_identifier").first
       result = struct_classification.new(classification.id, "#{classification.category}(#{classification.classification_identifier})")
    else
      result = []
      classifications = Classification
                          .where(["category like ? or classification_identifier like ? ", "#{params[:search_phrase]}%", "#{params[:search_phrase]}%"])
                          .where("classification_type_id = ?", params[:classification_type_id])
                          .select("id, category, classification_identifier")
                          .limit(10)
      classifications.each do |classification|
        result << struct_classification.new(classification.id, "#{classification.category}(#{classification.classification_identifier})")
      end
    end
    respond_to do |format|
      format.json { render :text => result.to_json }
    end
  end

end
