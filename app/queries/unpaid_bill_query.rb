class UnpaidBillQuery < PaginatedUnpaidQuery
  def initialize(relation = Bill.scoped)
    @relation = relation
  end
end
