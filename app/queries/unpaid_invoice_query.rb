class UnpaidInvoiceQuery < PaginatedUnpaidQuery
  def initialize(relation = Invoice.all)
    @relation = relation
  end
end