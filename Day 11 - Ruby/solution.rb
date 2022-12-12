MONKEY_OP = {
  times: 1,
  plus: 2,
  same: 3,
}

class Monkey

    def initialize(init_items, true_monkey, false_monkey, mod, op_type, other_op)
        @items_init = Marshal.load( Marshal.dump(init_items) )
        @items = init_items.clone
        @true_monkey = true_monkey
        @false_monkey = false_monkey
        @div_by = mod
        @op = op_type
        @other = other_op
        @inspect_cnt = 0
    end

    def reset()
        @items = @items_init
        @inspect_cnt = 0
    end

    def inspect(item)
        @inspect_cnt += 1
        if @op == MONKEY_OP[:times]
            return item * @other
        elsif @op == MONKEY_OP[:plus]
            return item + @other
        else
            return item * item
        end
    end

    def inspect_item(lcm, div_three)
        item = @items.shift
        if item == nil
            return nil, nil
        end
        new_worry = nil
        new_worry = inspect(item)
        if div_three
            new_worry = new_worry / 3
        end
        if (new_worry % @div_by) == 0
            return new_worry % lcm, @true_monkey
        else
            return new_worry % lcm, @false_monkey
        end
    end

    def get_inspected()
        return @inspect_cnt
    end

    def add_item(worry)
        @items[@items.length] = worry
    end

    def get_items()
        return @items
    end
end


def times_op(item, other)
    return item * other
end

def plus_op(item, other)
    return item + other
end

def same_op(item, other)
    return item * item
end

def get_input()
    monkeys = []
    start = []
    op = MONKEY_OP[:times]
    other_op = 1
    div_by = 1
    div_by_lst = []
    true_monkey = 1
    false_monkey = 2
    File.foreach('./input.txt', "\n") do |line|
        if line.start_with?("  Starting items:")
            items = line[17, line.length].split(', ', -1)
            start = []
            items.each do |item|
                start.append(item.to_i)
            end
        elsif line.start_with?("  Operation:")
            op_txt = line[23, line.length]
            if op_txt.include? "* old"
                op = MONKEY_OP[:same]
                other_op = 1
            elsif op_txt.include? "+"
                op = MONKEY_OP[:plus]
                other_op = op_txt[2, op_txt.length].to_i
            elsif op_txt.include? "*"
                op = MONKEY_OP[:times]
                other_op = op_txt[2, op_txt.length].to_i
            end
        elsif line.start_with?("  Test:")
            div_by = line[21, line.length].to_i
            div_by_lst.append(div_by)
        elsif line.start_with?("    If true:")
            true_monkey = line[29, line.length].to_i
        elsif line.start_with?("    If false:")
            false_monkey = line[30, line.length].to_i
            monkeys.append(Monkey.new(start, true_monkey, false_monkey, div_by, op, other_op))
        end
    end
    return monkeys, div_by_lst.reduce(1, :lcm)
end

def perform_rounds(rounds, monkeys, lcm, div_three)
    monkeys.each do |monkey|
        monkey.reset()
    end
    num = 0
    while num < rounds
        num += 1
        monkeys.each do |monkey|
            worry, new_monkey = monkey.inspect_item(lcm, div_three)
            while worry != nil
                monkeys[new_monkey].add_item(worry)
                worry, new_monkey = monkey.inspect_item(lcm, div_three)
            end
        end
    end
    insp_cnt = []
    monkeys.each do |monkey|
        insp_cnt.append(monkey.get_inspected())
    end
    insp_cnt.sort!
    return insp_cnt[insp_cnt.length-1]*insp_cnt[insp_cnt.length-2]
end

monkeys_1, lcm_1 = get_input()
print "Solution 1: ", perform_rounds(20, monkeys_1, lcm_1, true), "\n"
monkeys_2, lcm_2 = get_input()
print "Solution 2: ", perform_rounds(10000, monkeys_2, lcm_2, false), "\n"
