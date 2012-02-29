module ListTreeHelper
  #I hate to have to comment in here but, it's tricky.
  #This method takes a list of nodes in tree-order and produces a templated
  #tree of elements without making further SQL queries
  #
  #node_partial: the Rails-style path to a partial for each node in the tree
  #list_partial: the Rails-style path to a partial for collecting the children
  #of a node into a list'
  #nodes: the list of node in tree order
  def list_tree(node_partial, list_partial, nodes)
    stack = [[]]
    path = []
    (nodes + [nil]).each_cons(2) do |this, after|
      until path.empty? or path.last.is_ancestor_of?(this)
        children = (render :partial => list_partial, :locals => {:items => stack.pop, :path => path })
        stack.last << (render :partial => node_partial, :locals => { :node => path.pop, :path => path, :children => children })
      end
      if after.nil? or !this.is_ancestor_of?(after)
        stack.last << (render :partial => node_partial, :locals => { :node => this, :path => path })
      else
        path << this
        stack << []
      end
    end
    until path.empty?
      children = (render :partial => list_partial, :locals => {:items => stack.pop, :path => path })
      stack.last << (render :partial => node_partial, :locals => { :node => path.pop, :path => path, :children => children })
    end
    return render(:partial => list_partial, :locals => {:items => stack.last, :top_level => true}).html_safe
  end

  def depth_indicator(depth)
    str = ''
    if depth > 0
      depth.times do
        str << image_tag("/images/icons/spacer.png", :class=> "inline", :size =>"10x12", :alt => "&nbsp;&nbsp;&nbsp;")
      end
      str << image_tag("/images/icons/indent_arrow.png", :class=>"inline", :size => "12x12", :alt => '->')
    end
    str.html_safe
  end

end
