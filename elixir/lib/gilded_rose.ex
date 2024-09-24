defmodule GildedRose do
  # Example
  # update_quality([%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 9, quality: 1}])
  # => [%Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 8, quality: 3}]

  def update_quality(items) do
    Enum.map(items, &update_item/1)
  end

  @doc """
  When refactoring, I noticed that the code was going
  1. Update Quality
  2. Update Sell In
  3. Update Quality Again

  I decided to refactor the code to update the sell_in first, then update the quality.
  I believe this only made a difference for the Backstage passes, and infact solves a quality bug for the Backstage passes.
  """
  def update_item(item) do
    item
    |> update_item_sell_in()
    |> update_item_quality()
    |> check_max_min_quality()
  end

  @doc """
    At the end of each day, it decreases sell_in 1 for all items.

    However, Sulfuras, Hand of Ragnaros never has to be sold or decreases in quality.
    I chose to interpret `never has to be sold` as `never decreases sell_in`, or rather, never changes the sell_in.
  """
  def update_item_sell_in(%Item{name: "Sulfuras, Hand of Ragnaros"} = item), do: item
  def update_item_sell_in(%Item{} = item), do: %{item | sell_in: item.sell_in - 1}

  @doc """
  Sulfuras never changes in quality.

  Aged Brie increases in quality as it ages

  Backstage passes to a TAFKAL80ETC concert increases in quality as sell_in approaches
  - quality increases by 1 when there are more than 10 days remaining
  - quality increases by 2 when there are 6 to 10 days remaining
  - quality increases by 3 when there are 1-5 days remaining
  - quality drops to 0 after the concert

  Normal items decrease in quality
  - quality decreases by 1 when sell_in is greater than or equal to 0
  - quality decreases by 2 when sell_in is less than 0

  Conjured items decrease in quality twice as fast as normal items
  - quality decreases by 2 when sell_in is greater than or equal to 0
  - quality decreases by 4 when sell_in is less than 0

  """
  def update_item_quality(%Item{name: "Sulfuras, Hand of Ragnaros", quality: 80} = item), do: item

  def update_item_quality(%Item{name: "Sulfuras, Hand of Ragnaros", quality: _} = item),
    do: %{item | quality: 80}

  def update_item_quality(
        %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: sell_in} = item
      )
      when sell_in > 10 do
    new_quality = item.quality + 1

    %{item | quality: new_quality}
  end

  def update_item_quality(
        %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: sell_in} = item
      )
      when sell_in > 5 and sell_in < 11 do
    new_quality = item.quality + 2

    %{item | quality: new_quality}
  end

  def update_item_quality(
        %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: sell_in} = item
      )
      when sell_in >= 0 and sell_in < 5 do
    new_quality = item.quality + 3

    %{item | quality: new_quality}
  end

  def update_item_quality(
        %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: sell_in} = item
      )
      when sell_in < 0 do
    %{item | quality: 0}
  end

  def update_item_quality(%Item{name: "Aged Brie"} = item) do
    new_quality = item.quality + 1

    %{item | quality: new_quality}
  end

  def update_item_quality(%Item{name: "Conjured Mana Cake", sell_in: sell_in} = item)
      when sell_in >= 0 do
    new_quality = item.quality - 2

    %{item | quality: new_quality}
  end

  def update_item_quality(%Item{name: "Conjured Mana Cake", sell_in: sell_in} = item)
      when sell_in < 0 do
    new_quality = item.quality - 4

    %{item | quality: new_quality}
  end

  def update_item_quality(%Item{sell_in: sell_in} = item) when sell_in >= 0 do
    new_quality = item.quality - 1

    %{item | quality: new_quality}
  end

  def update_item_quality(%Item{sell_in: sell_in} = item) when sell_in < 0 do
    new_quality = item.quality - 2
    %{item | quality: new_quality}
  end

  @doc """
    The quality of an item is never negative.
    The quality of an item is never more than 50.
    The quality of Sulfuras, Hand of Ragnaros is always 80
  """
  def check_max_min_quality(%Item{name: "Sulfuras, Hand of Ragnaros"} = item), do: item

  def check_max_min_quality(%Item{quality: quality} = item) when quality >= 50 do
    %{item | quality: 50}
  end

  def check_max_min_quality(%Item{quality: quality} = item) when quality <= 0 do
    %{item | quality: 0}
  end

  def check_max_min_quality(item), do: item
end
