use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} <csv_file> <target_sum>", args[0]);
        std::process::exit(1);
    }

    let csv_file = &args[1];
    let target_sum: i32 = args[2].parse().expect("Invalid target sum");

    let points = read_csv(csv_file)?;
    let subsets = find_subsets(&points, target_sum);

    println!("Subsets with sum {}:", target_sum);
    for subset in subsets {
        println!("{:?}", subset);
    }

    Ok(())
}

fn read_csv<P: AsRef<Path>>(path: P) -> io::Result<Vec<(String, i32)>> {
    let file = File::open(path)?;
    let reader = io::BufReader::new(file);
    let mut points = Vec::new();

    for line in reader.lines() {
        let line = line?;
        let parts: Vec<&str> = line.split(',').collect();
        if parts.len() == 2 {
            let id = parts[0].trim().to_string();
            println!("val: {}", parts[1].trim_start_matches('"').trim_end_matches('"').trim());
            let value = (parts[1].trim_start_matches('"').trim_end_matches('"').trim().parse::<f64>().unwrap() * 100.0).round() as i32;
            points.push((id, value));
        }
    }

    Ok(points)
}

fn find_subsets(points: &[(String, i32)], target_sum: i32) -> Vec<Vec<(String, i32)>> {
    let mut dp: HashMap<i32, Vec<Vec<usize>>> = HashMap::new();
    dp.insert(0, vec![vec![]]);

    for (i, (_, value)) in points.iter().enumerate() {
        let mut new_sums = Vec::new();
        for (current_sum, subsets) in dp.iter() {
            let new_sum = current_sum + value;
            if new_sum <= target_sum {
                for subset in subsets {
                    let mut new_subset = subset.clone();
                    new_subset.push(i);
                    new_sums.push((new_sum, new_subset));
                }
            }
        }
        for (new_sum, new_subset) in new_sums {
            dp.entry(new_sum).or_insert_with(Vec::new).push(new_subset);
        }
    }

    dp.get(&target_sum)
        .map(|subsets| {
            subsets
                .iter()
                .map(|subset| {
                    subset
                        .iter()
                        .map(|&i| points[i].clone())
                        .collect::<Vec<_>>()
                })
                .collect::<Vec<_>>()
        })
        .unwrap_or_else(Vec::new)
}
