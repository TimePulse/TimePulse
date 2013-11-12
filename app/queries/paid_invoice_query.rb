class PaidInvoiceQuery < PaginatedPaidQuery
  def initialize(relation = Invoice.scoped)
    @relation = relation
  end
end