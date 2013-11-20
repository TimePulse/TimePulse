class UnpaidInvoiceQuery < PaginatedUnpaidQuery
  def initialize(relation = Invoice.scoped)
    @relation = relation
  end
end