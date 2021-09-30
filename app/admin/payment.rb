ActiveAdmin.register Payment, as: 'Payments' do


    actions :all, except: [:destroy, :new]


    controller do

      def scoped_collection
        super.where('amount != 0 and paid_at >= ? and paid_at <= ?', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      end

    end

    index do
      selectable_column
      column :id
      column :customer do |object|
        object&.objectable_type == "Booking" ? object&.objectable&.customer&.name : object&.objectable&.booking&.customer&.name
      end
      column "Booking id" do |object|
        object&.objectable_type == "Booking" ? object&.objectable&.id : object&.objectable&.booking&.id
      end
      column :payment_mode
      column :payment_type
      column :amount
      column :paid_at
    end

end
  