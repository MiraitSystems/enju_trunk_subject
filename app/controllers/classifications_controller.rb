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
    @sub_categories = Classification.get_sub_categories
    @check_category = 1;
  end

  def search_sub_category
    sub_category_number = params[:sub_category_number]
    @sub_category = ("#{sub_category_number}" + "00").to_i
    @max = @sub_category + 99
    @detail_categories = Classification.get_detail_categories(sub_category_number, @sub_category, @max)
    @check_category = 1;

    logger.error "######## #{@sub_category} ########"
    @search_param = []
    @sub_category.upto(@max) do |index| 
      if SystemConfiguration.get('manifestation.search.use_select2_for_classification') 
        if @detail_categories[index] 
          @search_param[index] = [{"classification_id" => "#{@detail_categories[index].id}", "classification_type_id" => "#{@detail_categories[index].classification_type_id}" }] 
        else 
          @search_param[index] = [{"classification_id" => nil, "classification_type_id" => "2" }] 
        end 
      else 
        @search_param[index] = [{"classification_identifier" => "#{sprintf("%03d",index)}", "classification_type_id" => "2" }] 
      end 
    end 
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
