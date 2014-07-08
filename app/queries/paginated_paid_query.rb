class PaginatedPaidQuery

  def find_for_page(page)
    @relation.paid.order(paid_on: :desc, created_at: :desc).paginate(:per_page => 10, :page => page)
  end

end
