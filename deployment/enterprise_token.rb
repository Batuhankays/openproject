# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require 'ostruct'

class EnterpriseToken < ApplicationRecord
  class << self
    def current
      RequestStore.fetch(:current_ee_token) do
        set_current_token
      end
    end

    def table_exists?
      connection.data_source_exists? table_name
    rescue StandardError => e
      warn "Failed to check enterprise_tokens table: #{e.message}"
      false
    end

    # PATCH: Bypass authorization service
    def allows_to?(action)
      true
    end

    # PATCH: Always active
    def active?
      true
    end

    def show_banners?
      false
    end

    def set_current_token
      # PATCH: Create mock token instead of fetching from DB
      token = new
      token.instance_variable_set(:@mock_mode, true)
      token.encoded_token = "mock_enterprise_token"
      token
    end
  end

  # Skip validations in mock mode
  validates :encoded_token, presence: true, unless: :mock_mode?
  validate :valid_token_object, unless: :mock_mode?
  validate :valid_domain, unless: :mock_mode?

  before_save :unset_current_token
  before_destroy :unset_current_token

  # Override all delegated methods
  def will_expire?
    false
  end

  def subscriber
    "Enterprise Edition"
  end

  def mail
    "enterprise@openproject.local"
  end

  def company
    "OpenProject Enterprise"
  end

  def domain
    "*"
  end

  def issued_at
    Time.now - 1.year
  end

  def starts_at
    Time.now - 1.year
  end

  def expires_at
    Time.now + 100.years
  end

  def reprieve_days
    nil
  end

  def reprieve_days_left
    nil
  end

  def restrictions
    {}
  end

  # Mock token object
  def token_object
    return @mock_token_object if defined?(@mock_token_object)
    
    @mock_token_object = OpenStruct.new(
      will_expire?: false,
      subscriber: "Enterprise Edition",
      mail: "enterprise@openproject.local",
      company: "OpenProject Enterprise",
      domain: "*",
      issued_at: Time.now - 1.year,
      starts_at: Time.now - 1.year,
      expires_at: Time.now + 100.years,
      reprieve_days: nil,
      reprieve_days_left: nil,
      restrictions: {},
      expired?: false,
      validate_domain?: false,
      valid_domain?: true
    )
  end

  # PATCH: Bypass authorization service
  def allows_to?(action)
    true
  end

  def unset_current_token
    RequestStore.delete :current_ee_token
  end

  def expired?(reprieve: true)
    false
  end

  def invalid_domain?
    false
  end

  private

  def mock_mode?
    @mock_mode == true
  end

  def load_token!
    token_object
  end

  def valid_token_object
    # Always valid in patch
    true
  end

  def valid_domain
    # Always valid in patch
    true
  end
end
