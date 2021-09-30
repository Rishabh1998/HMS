ActiveAdmin.register Permission, as: 'Permission' do

  actions :all, :except => [:edit, :destroy, :new]

  action_item :reload do
    link_to("Reload", "/admin/permissions/reload",  method: :post)
  end

  controller do
    def reload
      resource_collection = ActiveAdmin.application.namespaces[:admin].resources
      resources = resource_collection.select { |resource| resource.respond_to? :resource_class }

      resources.map { |resource|
        Permission.find_or_create_by(name: resource.resource_class.name, can: 'manage')
        Permission.find_or_create_by(name: resource.resource_class.name, can: 'read')
      }
      respond_to do |format|
        format.html { redirect_to request.referer}
      end
    end
  end
  index do
    selectable_column
    column :name
    column :can
    actions
  end

  filter :name
  filter :can

end
