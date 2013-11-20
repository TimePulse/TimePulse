class PaidBillQuery < PaginatedPaidQuery
  def initialize(relation = Bill.scoped)
    @relation = relation
  end
end
