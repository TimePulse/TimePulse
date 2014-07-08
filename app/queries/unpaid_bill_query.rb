class UnpaidBillQuery < PaginatedUnpaidQuery
  def initialize(relation = Bill.all)
    @relation = relation
  end
end
