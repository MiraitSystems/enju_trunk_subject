class ClassificationTypesController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource

  def update
    @classification_type = ClassificationType.find(params[:id])
    if @classification_type and params[:position]
      @classification_type.insert_at(params[:position])
      redirect_to classification_types_url
      return
    end
    update!
  end
end
