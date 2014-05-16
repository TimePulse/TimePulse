class PaidBillQuery < PaginatedPaidQuery
  def initialize(relation = Bill.all)
    @relation = relation
  end
end
