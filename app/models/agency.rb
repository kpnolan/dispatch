# == Schema Information
#
# Table name: agencies
#
#  id         :integer          not null, primary key
#  code       :string(2)
#  name       :string(63)
#  created_at :datetime
#  updated_at :datetime
#

class Agency < ActiveRecord::Base
end
