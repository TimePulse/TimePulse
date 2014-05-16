class PaidInvoiceQuery < PaginatedPaidQuery
  def initialize(relation = Invoice.all)
    @relation = relation
  end
end