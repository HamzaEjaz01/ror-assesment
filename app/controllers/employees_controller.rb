class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:edit, :show]

  def index
    @employees = EmployeeService.fetch_employees(params[:page])
  end

  def create
    employee = EmployeeService.create_employee(employee_params)
    redirect_to employee_path(employee['id'])
  end

  def update
    employee = EmployeeService.update_employee(params[:id], employee_params)
    redirect_to edit_employee_path(employee['id'])
  end

  private

  def employee_params
    params.permit(:name, :position, :date_of_birth, :salary)
  end

  def set_employee
    @employee = EmployeeService.fetch_employee(params[:id])
  end
end
