fn main() {
    // added the mutable keyword here since we need to modify the array
    let mut arr0 = ArrayTrait::new();

    let mut arr1 = fill_arr(arr0);

    print(arr1.span());

    arr1.append(88);

    print(arr1.span());
}

// added the mutable keyword in the parameter here
fn fill_arr(mut arr: Array<felt252>) -> Array<felt252> {
    arr.append(22);
    arr.append(44);
    arr.append(66);

    arr
}

fn print(span: Span<felt252>) { 
    let mut i = 0;
    print!("ARRAY: {{ len: {}, values: [ ", span.len());
    loop {
        if span.len() == i {
            break;
        }
        let value = *(span.at(i));
        if span.len() - 1 != i {
            print!("{}, ", value);
        } else {
            print!("{}", value);
        }
        i += 1;
    };
    println!(" ] }}");
}