defmodule GildedRoseTest do
  use ExUnit.Case

  describe "update_quality" do
    test "begin the journey of refactoring" do
      items = [%Item{name: "foo", sell_in: 0, quality: 0}]
      GildedRose.update_quality(items)
      first_item = List.first(items)
      assert "foo" == first_item.name
    end
  end

  describe "update_item/1" do
    test "Normal items quality can be zero" do
      item = %Item{name: "foo", sell_in: 0, quality: 1}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 0
    end

    test "Normal items quality can't be negative" do
      item = %Item{name: "foo", sell_in: 0, quality: 0}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 0
    end

    test "Normal items sell_in can be negative" do
      item = %Item{name: "foo", sell_in: 0, quality: 0}
      updated_item = GildedRose.update_item(item)
      assert updated_item.sell_in == -1
    end

    test "Normal items degrade by 1 for both sell_in and quality each day" do
      item = %Item{name: "foo", sell_in: 1, quality: 1}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 0
      assert updated_item.sell_in == 0
    end

    test "Normal items quality degrades twice as fast when sell_in is negative" do
      item = %Item{name: "foo", sell_in: -1, quality: 4}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 2
      assert updated_item.sell_in == -2

      second_update = GildedRose.update_item(updated_item)
      assert second_update.quality == 0
      assert second_update.sell_in == -3
    end

    test "Normal items quality can't be more than 50" do
      item = %Item{name: "foo", sell_in: 1, quality: 60}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 50
    end

    test "Sulfuras quality never changes" do
      item = %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 1, quality: 80}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 80
    end

    test "Sulfuras sell_in never changes" do
      item = %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 2, quality: 80}
      updated_item = GildedRose.update_item(item)
      assert updated_item.sell_in == 2
    end

    test "Aged Brie increases in quality as it ages" do
      item = %Item{name: "Aged Brie", sell_in: 1, quality: 1}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 2
      assert updated_item.sell_in == 0
    end

    test "Aged Brie quality can't be more than 50" do
      item = %Item{name: "Aged Brie", sell_in: 1, quality: 49}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 50
      assert updated_item.sell_in == 0

      updated_item_again = GildedRose.update_item(updated_item)
      assert updated_item_again.quality == 50
      assert updated_item_again.sell_in == -1
    end

    test "Backstage passes increase in quality as sell_in approaches" do
      item = %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 12, quality: 1}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 2
      assert updated_item.sell_in == 11
    end

    test "Backstage passes increase in quality by 2 when there are 6 to 10 days remaining" do
      # At the end of each day, it decreases sell_by 1. I am testing sell_bys for 6 to 10, so I start with 7-11
      Enum.each(7..11, fn days_remaining ->
        item = %Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          sell_in: days_remaining,
          quality: 1
        }

        updated_item = GildedRose.update_item(item)
        assert updated_item.quality == 3
      end)
    end

    test "Backstage passes increase in quality by 3 when there are 1-5 days remaining" do
      Enum.each(1..5, fn days_remaining ->
        item = %Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          sell_in: days_remaining,
          quality: 1
        }

        updated_item = GildedRose.update_item(item)
        assert updated_item.quality == 4
      end)
    end

    test "Backstage passes quality drops to 0 after the concert" do
      item = %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 0, quality: 1}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 0
    end

    test "Backstages passes quality can't be more than 50" do
      item = %Item{name: "Backstage passes to a TAFKAL80ETC concert", sell_in: 1, quality: 49}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 50
    end

    test "Conjured items degrade in quality twice as fast as normal items when sell_in is not negative" do
      item = %Item{name: "Conjured Mana Cake", sell_in: 3, quality: 6}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 4
      assert updated_item.sell_in == 2
    end

    test "Conjured items degrade in quality twice as fast as normal items when sell_in is negative" do
      item = %Item{name: "Conjured Mana Cake", sell_in: -1, quality: 6}
      updated_item = GildedRose.update_item(item)
      assert updated_item.quality == 2
      assert updated_item.sell_in == -2
    end
  end

  describe "update_item_sell_in/1" do
    test "doesn't change sell_in for Sulfuras" do
      item = %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 1, quality: 80}
      updated_item = GildedRose.update_item_sell_in(item)
      assert updated_item.sell_in == 1
    end

    test "decreases sell_in for all items" do
      item = %Item{name: "foo", sell_in: 1, quality: 1}
      updated_item = GildedRose.update_item_sell_in(item)
      assert updated_item.sell_in == 0
    end
  end

  describe "check_max_min_quality/1" do
    test "quality can't be negative" do
      item = %Item{name: "foo", sell_in: 1, quality: -1}
      updated_item = GildedRose.check_max_min_quality(item)
      assert updated_item.quality == 0
    end

    test "quality can't be more than 50" do
      item = %Item{name: "foo", sell_in: 1, quality: 51}
      updated_item = GildedRose.check_max_min_quality(item)
      assert updated_item.quality == 50
    end

    test "Sulfuras is left alone" do
      item = %Item{name: "Sulfuras, Hand of Ragnaros", sell_in: 1, quality: 80}
      updated_item = GildedRose.check_max_min_quality(item)
      assert updated_item.quality == 80
    end

    test "quality between 0 and 50 is left alone" do
      item = %Item{name: "foo", sell_in: 1, quality: 1}
      updated_item = GildedRose.check_max_min_quality(item)
      assert updated_item.quality == 1
    end
  end
end
